#SUBDIRS( MiniCL BulletMultiThreaded BulletSoftBody BulletCollision BulletDynamics LinearMath )
SUBDIRS( BulletSoftBody BulletCollision BulletDynamics LinearMath )

IF(INSTALL_LIBS)
	#INSTALL of other files requires CMake 2.6
	IF (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 2.5)
		IF (APPLE AND BUILD_SHARED_LIBS AND FRAMEWORK)
			# Don't actually need to install any common files, the frameworks include everything
		ELSE (APPLE AND BUILD_SHARED_LIBS AND FRAMEWORK)
			INSTALL(FILES btBulletCollisionCommon.h
btBulletDynamicsCommon.h Bullet-C-Api.h DESTINATION ${INCLUDE_INSTALL_DIR})
		ENDIF (APPLE AND BUILD_SHARED_LIBS AND FRAMEWORK)
	ENDIF (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 2.5)
ENDIF(INSTALL_LIBS)
