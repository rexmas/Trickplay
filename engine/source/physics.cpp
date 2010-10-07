
#include "physics.h"
#include "app.h"
#include "clutter_util.h"
#include "lb.h"
#include "util.h"

namespace Physics
{

static Debug_ON plog;

//.............................................................................

World::World( lua_State * _L , ClutterActor * _screen , float32 _pixels_per_meter )
:
    ppm( _pixels_per_meter ),
    L( _L ),
    world( b2Vec2( 0.0f , 10.0f ) , true ),
    next_handle( 1 ),
    velocity_iterations( 6 ),
    position_iterations( 2 ),
    idle_source( 0 ),
    timer( g_timer_new() ),
    screen( CLUTTER_ACTOR( g_object_ref( _screen ) ) )
{
    world.SetContactListener( this );
}

//.............................................................................

World::~World()
{
    // Remove the collision listener so we don't get callbacks while
    // destroying the world.

    world.SetContactListener( 0 );

    // Stop our idle source and destroy the timer

    stop();

    g_timer_destroy( timer );

    // Tell all the body wrappers that their b2Body is going away

    for( b2Body * body = world.GetBodyList(); body; body = body->GetNext() )
    {
        Body::body_destroyed( body );
    }

    // Let go of the screen

    g_object_unref( screen );
}

//.............................................................................

void World::start( int _velocity_iterations , int _position_iterations )
{
    if ( idle_source )
    {
        return;
    }

    idle_source = clutter_threads_add_idle( on_idle , this );

    g_timer_start( timer );

    velocity_iterations = _velocity_iterations;
    position_iterations = _position_iterations;
}

//.............................................................................

void World::stop()
{
    if ( ! idle_source )
    {
        return;
    }

    g_source_remove( idle_source );

    idle_source = 0;
}

//.............................................................................

void World::step( float32 time_step , int _velocity_iterations , int _position_iterations )
{
    world.Step( time_step , _velocity_iterations , _position_iterations );

    for( b2Body * body = world.GetBodyList(); body; body = body->GetNext() )
    {
        if ( ! body->IsAwake() || ! body->IsActive() )
        {
            continue;
        }

        Body::synchronize_actor( body );
    }
}

//.............................................................................

gboolean World::on_idle( gpointer me )
{
    World * self = ( World * ) me;

    float32 seconds = g_timer_elapsed( self->timer , NULL );

    g_timer_start( self->timer );

    self->step( seconds , self->velocity_iterations , self->position_iterations );

    return TRUE;
}

//.............................................................................

int World::create_body( int properties , lua_CFunction constructor )
{
    luaL_checktype( L , properties , LUA_TTABLE );

    g_assert( constructor );

    //.........................................................................
    // Get the actor/source

    lua_getfield( L , properties , "source" );

    ClutterActor * actor = ClutterUtil::user_data_to_actor( L , lua_gettop( L ) );

    lua_pop( L , 1 );

    if ( ! actor )
    {
        return luaL_error( L , "Invalid or missing body source" );
    }

    //.........................................................................
    // The body defintion

    b2BodyDef bd;

    //.........................................................................
    // Get the width and height of the actor

    gfloat width;
    gfloat height;

    clutter_actor_get_size( actor , & width , & height );

    //.........................................................................
    // Move the anchor point to the center of the actor. This doesn't change
    // its position relative to its parent.

    clutter_actor_move_anchor_point( actor , width / 2.0f , height / 2.0f );

    //.........................................................................
    // Get the screen position of the actor's anchor point, convert it to world
    // coordinates and set it in the body definition.

    gfloat x;
    gfloat y;

    clutter_actor_get_position( actor , & x , & y );

    bd.position.x = screen_to_world( x );
    bd.position.y = screen_to_world( y );

    //.........................................................................
    // Populate the rotation of the body from the actor's z rotation.

    bd.angle = degrees_to_radians( clutter_actor_get_rotation( actor , CLUTTER_Z_AXIS , 0 , 0 , 0 ) );

    //.........................................................................
    // Set the body type - dynamic by default

    bd.type = b2_dynamicBody;

    //.........................................................................
    // Ready to create the body

    b2Body * body = world.CreateBody( & bd );

    if ( ! body )
    {
        g_warning( "FAILED TO CREATE PHYSICS BODY" );
        return 0;
    }

    //.........................................................................
    // The properties table can also have default fixture attributes, so
    // we create a fixture def using the same table.

    b2FixtureDef fd = create_fixture_def( properties );

    //.........................................................................
    // If the user did not pass a shape for the fixture, we create a default
    // polygon.

    b2PolygonShape box;

    if ( ! fd.shape )
    {
        box.SetAsBox( screen_to_world( height / 2.0f ) , screen_to_world( width / 2.0f ) );

        fd.shape = & box;
    }

    //.........................................................................
    // Set the handle for the fixture

    fd.userData = get_next_handle_as_pointer();

    //.........................................................................
    // Create the fixture

    body->CreateFixture( & fd );

    //.........................................................................
    // Create the body wrapper for it. This sets up all the relationships and
    // user data pointers.

    Body * bw = new Body( this , body , actor );

    //.........................................................................
    // Push the body wrapper as a light user data onto the Lua stack and invoke
    // the constructor function.

    lua_pushlightuserdata( L , bw );

    LSG;

    int result = constructor( L );

    g_assert( result == 1 );

    LSG_CHECK( 1 );

    //.........................................................................
    // Now, we get rid of the light user data. After this, the real user
    // data newly created should be on the top of the stack.

    lua_remove( L , -2 );

    //.........................................................................
    // This gives the body wrapper a chance to create a handle to itself -
    // so it doesn't get collected until the actor goes away.

    bw->create_ud_handle( L );

    return 1;
}

//.............................................................................

b2FixtureDef World::create_fixture_def( int properties )
{
    b2FixtureDef fd;

    //.........................................................................
    // Friction

    lua_getfield( L , properties , "friction" );
    if ( ! lua_isnil( L , -1 ) )
    {
        fd.friction = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Restitution aka bounce

    lua_getfield( L , properties , "restitution" );
    if ( ! lua_isnil( L , -1 ) )
    {
        fd.restitution = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    lua_getfield( L , properties , "bounce" );
    if ( ! lua_isnil( L , -1 ) )
    {
        fd.restitution = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Density

    lua_getfield( L , properties , "density" );
    if ( ! lua_isnil( L , -1 ) )
    {
        fd.density = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Sensor

    lua_getfield( L , properties , "sensor" );
    if ( ! lua_isnil( L , -1 ) )
    {
        fd.isSensor = lua_toboolean( L , -1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Collision filter

    lua_getfield( L , properties , "filter" );
    if ( lua_istable( L , -1 ) )
    {
        int f = lua_gettop( L );

        lua_getfield( L , f , "group" );
        if ( ! lua_isnil( L , -1 ) )
        {
            fd.filter.groupIndex = lua_tointeger( L , -1 );
        }
        lua_pop( L , 1 );

        lua_getfield( L , f , "category" );
        if ( lua_isnumber( L , -1 ) )
        {
            fd.filter.categoryBits = 1 << lua_tointeger( L , -1 );
        }
        else if ( lua_istable( L , -1 ) )
        {
            fd.filter.categoryBits = 0;

            int t = lua_gettop( L );

            lua_pushnil( L );

            while( lua_next( L , t ) )
            {
                if ( lua_isnumber( L , -1 ) )
                {
                    fd.filter.categoryBits |= 1 << lua_tointeger( L , -1 );
                }
                lua_pop( L , 1 );
            }
        }
        lua_pop( L , 1 );

        lua_getfield( L , f , "mask" );
        if ( lua_isnumber( L , -1 ) )
        {
            fd.filter.maskBits = 1 << lua_tointeger( L , -1 );
        }
        else if ( lua_istable( L , -1 ) )
        {
            fd.filter.maskBits = 0;

            int t = lua_gettop( L );

            lua_pushnil( L );

            while( lua_next( L , t ) )
            {
                if ( lua_isnumber( L , -1 ) )
                {
                    fd.filter.maskBits |= 1 << lua_tointeger( L , -1 );
                }
                lua_pop( L , 1 );
            }
        }
        lua_pop( L , 1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Shape

    lua_getfield( L , properties , "shape" );
    if ( lua_isuserdata( L , -1 ) )
    {
        fd.shape = ( b2Shape * ) UserData::get_client( L , lua_gettop( L ) );
    }
    lua_pop( L , 1 );

    return fd;
}


//=============================================================================
// ContactListener callbacks

void World::BeginContact( b2Contact * contact )
{
    // TODO:
}

//.............................................................................

void World::EndContact( b2Contact * contact )
{
    // TODO:
}

//.............................................................................

void World::PreSolve( b2Contact * contact , const b2Manifold * oldManifold )
{
    // TODO:
}

//.............................................................................

void World::PostSolve( b2Contact * contact , const b2ContactImpulse * impulse )
{
    // TODO:
}

//.............................................................................


//=========================================================================

//.............................................................................
// This wrapper is owned by the Lua proxy for the body, but the actor will
// force the Lua proxy to stay alive as long as it lives. Once the actor
// dies, it will destroy the b2Body and nullify the body wrapper. It will
// also let go of its handle to the Lua proxy - which means it can be
// collected. However, if the user still has a reference to the Lua proxy,
// that proxy will be invalid - since its body wrapper has no b2Body or
// actor.

Body::Body( World * _world , b2Body * _body , ClutterActor * _actor )
:
    world( _world ),
    body( _body ),
    actor( _actor ),
    ud_handle( 0 )
{
    g_assert( world );
    g_assert( body );
    g_assert( actor );

    handle = world->get_next_handle();

    // Give a pointer to the b2Body

    body->SetUserData( this );

    // Give a pointer to the actor

    g_object_set_qdata_full( G_OBJECT( actor ) , get_actor_body_quark() , this , ( GDestroyNotify ) destroy_actor_body );

    // Set the active state of the body based on whether the actor is mapped

    body->SetActive( CLUTTER_ACTOR_IS_MAPPED( actor ) );

    // Attach a signal handler to be notified when the actor's mapped property changes

    mapped_handler = g_signal_connect_after( G_OBJECT( actor ) , "notify::mapped" , ( GCallback ) actor_mapped_notify , this );


    plog( "CREATED BODY %d : %p : b2body %p : actor %p" , handle , this , body , actor );
}

//.............................................................................
// We may get destroyed before the actor, when the Lua state is closing

Body::~Body()
{
    plog( "DESTROYING BODY %d : %p : b2body %p : actor %p" , handle , this , body , actor );

    if ( actor )
    {
        // This will end up calling destroy_actor_body below

        g_object_set_qdata( G_OBJECT( actor ) , get_actor_body_quark() , 0 );
    }
}

//.............................................................................
// There is a user data on the top of the Lua stack that points to me.
// I create a handle so that I won't be collected.

void Body::create_ud_handle( lua_State * L )
{
    g_assert( ud_handle == 0 );

    g_assert( UserData::get_client( L , lua_gettop( L ) ) == this );

    ud_handle = UserData::Handle::make( L , lua_gettop( L ) );

    g_assert( ud_handle );
}

//.............................................................................
// The b2Body may get destroyed when the world is destroyed...:)

void Body::body_destroyed( b2Body * body )
{
    plog( "B2BODY BEING DESTROYED" );

    if ( Body * self = Body::get_from_body( body ) )
    {
        plog( "CLEARING B2BODY %d : %p : b2body %p : actor %p" , self->handle , self , self->body , self->actor );

        self->body = 0;
    }
}

//.............................................................................
// The actor is being destroyed - that means that the b2Body will be destroyed
// as well. This structure loses its body and actor members.


void Body::destroy_actor_body( Body * self )
{
    plog( "CLEARING ACTOR BODY %d : %p : b2body %p : actor %p" , self->handle , self , self->body , self->actor );

    // Nullify the body's user data

    if ( self->body )
    {
        self->body->SetUserData( 0 );

        self->body->SetActive( false );

        // TODO: b2Bodies cannot be destroyed during callbacks. So, if an actor is
        // collected during a collision callback, for example, the call to destroy the
        // associated b2Body will fail.

        self->body->GetWorld()->DestroyBody( self->body );

        self->body = 0;
    }

    g_assert( self->actor );

    g_signal_handler_disconnect( self->actor , self->mapped_handler );

    self->actor = 0;

    // This is the master object that controls the Lua proxy for this
    // wrapper. We let it go, so that the Lua proxy can be collected.

    g_assert( self->ud_handle );

    UserData::Handle::destroy( self->ud_handle );

    self->ud_handle = 0;
}

//.............................................................................

Body * Body::get_from_actor( ClutterActor * actor )
{
    return ! actor ? 0 : ( Body * ) g_object_get_qdata( G_OBJECT( actor ) , get_actor_body_quark() );
}

//.............................................................................

Body * Body::get_from_body( b2Body * body )
{
    return ! body ? 0 : ( Body * ) body->GetUserData();
}

//.............................................................................

Body * Body::get_from_lua( lua_State * L , int index )
{
    return ( Body * ) UserData::get_client( L , index );
}

//.............................................................................

GQuark Body::get_actor_body_quark()
{
    static const gchar * k = "tp-physics_body";

    static GQuark q = g_quark_from_static_string( k );

    return q;
}

//.............................................................................

void Body::synchronize_actor()
{
    if ( actor && body )
    {
        const b2Vec2 & pos( body->GetPosition() );

        clutter_actor_set_position( actor , world->world_to_screen( pos.x ) , world->world_to_screen( pos.y ) );

        clutter_actor_set_rotation( actor , CLUTTER_Z_AXIS , World::radians_to_degrees( body->GetAngle() ) , 0 , 0 , 0 );
    }
}

//.............................................................................

void Body::synchronize_actor( b2Body * body )
{
    if ( Body * b = Body::get_from_body( body ) )
    {
        b->synchronize_actor();
    }
}

//.............................................................................

void Body::synchronize_body()
{
    if ( actor && body )
    {
        gfloat x;
        gfloat y;

        clutter_actor_get_position( actor , & x , & y );

        float32 angle = clutter_actor_get_rotation( actor , CLUTTER_Z_AXIS , 0 , 0 , 0 );

        x = world->screen_to_world( x );
        y = world->screen_to_world( y );

        angle = World::degrees_to_radians( angle );

        body->SetTransform( b2Vec2( x , y ) , angle );
    }
}

//.............................................................................

void Body::actor_mapped_notify( GObject * , GParamSpec * , Body * self )
{
    //plog( "ACTOR MAPPED CHANGED %p : %s" , self , CLUTTER_ACTOR_IS_MAPPED( self->actor ) ? "TRUE" : "FALSE" );

    if ( self->actor && self->body )
    {
        bool mapped = CLUTTER_ACTOR_IS_MAPPED( self->actor );

        self->body->SetActive( mapped );

        // The actor is back on the screen, we update the body's position

        if ( mapped )
        {
            self->synchronize_body();
        }
    }
}

//.............................................................................

}; // Physics
