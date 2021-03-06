import uuid
import hashlib

class Call(object):

    def __init__(self, user, sender_uri, remote_uri,
                 udp_client_ip, udp_client_port, udp_server_port, write_queue):
        # This is your user name
        self.user = user
        # This is your contact uri
        self.sender_uri = sender_uri
        # This is the original destination uri; this stays constant
        self.remote_uri = remote_uri
        self.udp_client_ip = udp_client_ip
        self.udp_client_port = udp_client_port
        self.udp_server_port = udp_server_port
        self.write_queue = write_queue

        # This is the destination uri; this is not constant.
        # Used in the Request line and the md5 authentication.
        # This uri will be updated as SIP discovers the final destination uri.
        self.sip_uri = remote_uri

        # Used to record the SIP route taken by a request and used to route the response
        # back to the originator.
        # UAs generating a request records its own address in a Via 
        # and adds it to the header.
        # Order of Via header fields is significant as it determines routes
        self.Via = {
            1 : {
                'protocol' : "SIP/2.0/UDP",
                'client_ip' : udp_client_ip,
                'client_port' : str(udp_client_port)
            }
        }

        # How many times can this bounce around the network?
        self.Max_Forwards = '70'

        # Where is this sending from? tag is generated locally (UAC)
        self.From = {
            'sender' : '<' + sender_uri + '>',
            'tag' : uuid.uuid4().hex,
        }

        # Who are you calling? tag is generated by UAS
        self.To = {
            'remote_contact' : '<' + remote_uri + '>',
            'tag' : ""
        }

        # All Calls are tied to a specific Call-ID. OPTIONS always
        # has a unique Call-ID. All REGISTERs from the same UA have the
        # same Call-ID.
        self.Call_ID = str(uuid.uuid4())

        # Sequence Number, increments per request for same call.
        # Exception is ACK or CANCEL where it uses the CSeq number of the INVITE
        # it's referencing.
        self.CSeq = 101

        # This is your routable address. The SIP Server caches this and forwards
        # all outside requests to this address therfore this must reference
        # your address outside the NAT. All INVITES and 200 responses must have
        # a Contact. REGISTERs may have Contact: * to remove all existing
        # Registrations.
        self.Contact = "<sip:" + user + "@" + udp_client_ip + ":" + str(udp_client_port) + ">"

        # A useless name you can include, may help with logs on server side
        self.User_Agent = "Python"

        # These are the Requests we allow. All of these should be implemented to complete
        # this project.
        self.Allow = "INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE"

        # This is additional stuff you support. NOTE: we don't support any of it. But
        # Entropy does in the Wireshark packets so I'm including it now anyway.
        # May support it later, who knows?
        self.Supported = "timer, 100rel, path"

        # Strings to help with Authorization
        self.Auth_1 = 'Authorization: Digest username="phone", realm="asterisk", nonce="'
        self.Auth_2 = '", algorithm=MD5, uri="sip:asterisk-1.asterisk.trickplay.com", response="'

        # Default Content length of 0 indicates no message body
        self.Content_Length = "Content-Length: 0\r\n\r\n"

        self.branch = None
        self.nonce = None
        self.auth = None

        self.states = ("UNREGISTERED", "REGISTERED")
        self.current_state = 0

        self.callback = None


    def gen_auth_line(self, request_type):
        if not self.nonce or not self.sip_uri or not request_type:
            return None

        ha1 = hashlib.md5(self.user + ":asterisk:saywhat").hexdigest()
        ha2 = hashlib.md5(request_type + ":" + self.sip_uri).hexdigest()
        ha3 = hashlib.md5(ha1 + ":" + self.nonce + ":" + ha2).hexdigest()

        auth = 'Authorization: Digest username="' + self.user + '", realm="asterisk", ' + \
                'nonce="' + self.nonce + '", algorithm=MD5, uri="' + self.sip_uri + '", '\
                'response="' + ha3 + '"\r\n'

        return auth


    def gen_branch(self):
        """Use to create a unique branch id"""

        # branch must begin with that weird 7 character string
        return 'z9hG4bK' + uuid.uuid4().hex


    def gen_sdp(self):
        sdp_header = "v=0\r\n" + \
        "o=- 0 0 IN IP4 " + self.udp_client_ip + "\r\n" + \
        "s=" + self.user + "\r\n" + \
        "c=IN IP4 " + self.udp_client_ip + "\r\n" + \
        "t=0 0\r\n" + \
        "a=range:npt=now-\r\n" +\
        "m=audio 7078 RTP/AVP 96\r\n" + \
        "b=AS:64\r\n" + \
        "a=rtpmap:96 mpeg4-generic/44100/1\r\n" + \
        "a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n" + \
        "m=video 9078 RTP/AVP 97\r\n" + \
        "b=AS:1372\r\n" + \
        "a=rtpmap:97 H264/90000\r\n" + \
        "a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n" + \
        "mpeg4-esid:201\r\n"
 
        return sdp_header

    def gen_sdp_asterisk(self):
        sdp_header = "v=0\r\n" + \
        "o=- 0 0 IN IP4 " + self.udp_client_ip + "\r\n" + \
        "s=" + self.user + "\r\n" + \
        "c=IN IP4 " + self.udp_client_ip + "\r\n" + \
        "t=0 0\r\n" + \
        "a=range:npt=now-\r\n" +\
        "m=audio 7078 RTP/AVP 0\r\n" + \
        "a=rtpmap:0 PCMU/8000\r\n" + \
        "a=sendrecv\r\n" + \
        "m=video 9078 RTP/AVP 97\r\n" + \
        "b=AS:1372\r\n" + \
        "a=rtpmap:97 H264/90000\r\n" + \
        "a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n" + \
        "mpeg4-esid:201\r\n"

        return sdp_header


    def pull_server_tag(self, response):
        if 'To' not in response:
            return False

        to_line = response['To']
        if to_line.find('tag=') >= 0:
            begin = to_line.find('tag=')
            self.To['tag'] = to_line[begin+4:]
            print "\nserver tag: " + self.To['tag'] + "\n\n"

            return True

        return False

    
    def pull_nonce(self, response):
        if 'WWW-Authenticate' not in response:
            return False

        auth_line = response['WWW-Authenticate']
        if auth_line.find('nonce="') >= 0:
            begin = auth_line.find('nonce="')
            start = auth_line.find('"', begin)
            end = auth_line.find('"', start+1)
            self.nonce = auth_line[start+1:end]
            print "\nnonce: " + self.nonce + "\n\n"

            return True

        return False


    def interpret(self, response):
        print "You should overwrite this"



class Register(Call):

    def gen_register(self, authorization):
        """Create and return a REGISTER packet"""

        # generate new branch id
        self.branch = self.gen_branch()

        # build REGISTER packet
        register = "REGISTER sip:asterisk-1.asterisk.trickplay.com SIP/2.0\r\n"
        register += "Via: " + self.Via[1]['protocol'] + " " + self.Via[1]['client_ip'] + \
                    ":" + self.Via[1]['client_port'] + ";rport;branch=" + self.branch + \
                    "\r\n"
        register += "Max-Forwards: " + self.Max_Forwards + "\r\n"
        register += "From: " + self.From['sender'] + ";tag=" + self.From['tag'] + "\r\n"
        register += "To: " + self.From['sender'] + "\r\n"
        register += "Call-ID: " + self.Call_ID + "\r\n"
        register += "CSeq: " + str(self.CSeq) + " REGISTER\r\n"
        register += "Contact: " + self.Contact + "\r\n"
        register += "User-Agent: " + self.User_Agent + "\r\n"
        register += "Allow: " + self.Allow + "\r\n"
        register += "Supported: " + self.Supported + "\r\n"

        # add authorization line if available
        if authorization:
            register += authorization

        # terminate with default Content-Length of 0
        register += self.Content_Length

        # increment sequence number
        self.CSeq += 1

        return register


    def register(self):
        """Register to the SIP Server"""

        # if authorization key exists then generate auth line
        auth = None
        if self.nonce:
            ha1 = hashlib.md5("phone:asterisk:saywhat").hexdigest()
            ha2 = hashlib.md5("REGISTER:sip:asterisk-1.asterisk.trickplay.com").hexdigest()
            ha3 = hashlib.md5(ha1 + ":" + self.nonce + ":" + ha2).hexdigest()

            auth = self.Auth_1 + self.nonce + self.Auth_2 + ha3 + '"\r\n'

        # create REGISTER packet
        packet = self.gen_register(auth)

        # send over network
        self.write_queue.append(packet)


    def interpret(self, response):
        if response['Status-Line'] == "SIP/2.0 200 OK":
            self.current_state = 1
            if self.callback:
                self.callback()
        elif response['Status-Line'] == "SIP/2.0 401 Unauthorized":
            if self.pull_nonce(response):
                self.register()
        
        print "\ncurrent state:", self.states[self.current_state], '\n\n'


class Options(Call):
    
    def gen_response(self, call, addr):
        via = call['Via'].split(';')

        packet = "SIP/2.0 200 OK\r\n" + \
        "Via: " + via[0] + ';' + via[1] + ";rport=" + str(addr[1]) + ";received=" + addr[0] + "\r\n" + \
        "From: " + call['From'] + "\r\n" + \
        "To: " + call['To'] + ';tag=' + self.From['tag'] + "\r\n" + \
        "Call-ID: " + call['Call-ID'] + "\r\n" + \
        "CSeq: " + call['CSeq'] + "\r\n" + \
        "Contact: " + self.Contact + "\r\n" + \
        "User-Agent: " + self.User_Agent + "\r\n" + \
        "Accept: application/sdp\r\n" + \
        "Allow: INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE\r\n" + \
        "Supported: timer, 100rel\r\n" + \
        self.Content_Length

        return packet


    def incoming_options(self, call, addr):
        """Respond to an incoming OPTIONS call""" 

        packet = self.gen_response(call, addr)
        self.write_queue.append(packet)


class Bye(Call):
    
    def gen_response(self, call, addr):
        via = call['Via'].split(';')

        packet = "SIP/2.0 200 OK\r\n" + \
        "Via: " + via[0] + ';' + via[1] + ";rport=" + str(addr[1]) + ";received=" + addr[0] + "\r\n" + \
        "From: " + call['From'] + "\r\n" + \
        "To: " + call['To'] + "\r\n" + \
        "Call-ID: " + call['Call-ID'] + "\r\n" + \
        "CSeq: " + call['CSeq'] + "\r\n" + \
        self.Content_Length

        return packet

    def incoming_bye(self, call, addr):
        """Respond to an incoming BYE call"""

        packet = self.gen_response(call, addr)
        self.write_queue.append(packet)


class Invite(Call):
    def __init__(self, user, sender_uri, remote_uri,
                 udp_client_ip, udp_client_port, udp_server_port, write_queue):
        super(Invite, self).__init__(user, sender_uri, remote_uri,
                 udp_client_ip, udp_client_port, udp_server_port, write_queue)
        self.sent_invite = False
        self.received_100 = False
        self.received_200 = False
        self.sent_ack = False

    def reset(self):
        self.sent_invite = False
        self.received_100 = False
        self.received_200 = False
        self.sent_ack = False
    
    def gen_invite(self, authorization):
        """Create and return an INVITE packet"""

        # generate new branch id
        self.branch = self.gen_branch()

        # build INVITE packet
        invite = "INVITE " + self.sip_uri + " SIP/2.0\r\n"
        invite += "Via: " + self.Via[1]['protocol'] + " " + self.Via[1]['client_ip'] + \
                    ":" + self.Via[1]['client_port'] + ";rport;branch=" + self.branch + \
                    "\r\n"
        invite += "Max-Forwards: " + self.Max_Forwards + "\r\n"
        invite += "From: " + self.From['sender'] + ";tag=" + self.From['tag'] + "\r\n"
        invite += "To: " + self.To['remote_contact'] + "\r\n"
        invite += "Call-ID: " + self.Call_ID + "\r\n"
        invite += "CSeq: " + str(self.CSeq) + " INVITE\r\n"
        invite += "Contact: " + self.Contact + "\r\n"
        invite += "User-Agent: " + self.User_Agent + "\r\n"
        invite += "Allow: " + self.Allow + "\r\n"
        invite += "Supported: " + self.Supported + "\r\n"

        # add authorization line if available
        if authorization:
            invite += authorization

        # add sdp
        #sdp_packet = self.gen_sdp()
        sdp_packet = self.gen_sdp_asterisk()

        invite += 'Content-Length: ' + str(len(sdp_packet)) + '\r\n\r\n'
        invite += sdp_packet

        # increment sequence number
        self.CSeq += 1

        return invite


    def invite(self):
        """Register to the SIP Server"""

        # if authorization key exists then generate auth line
        self.auth = self.gen_auth_line("INVITE")

        # create INVITE packet
        packet = self.gen_invite(self.auth)

        # send over network
        self.write_queue.append(packet)
        self.sent_invite = True

    
    def gen_ack(self, authorization):
        """Send an ACK to an INVITE"""
        # TODO: handle end-to-end ack differently
        # generate new branch id
        self.branch = self.gen_branch()

        tag = ""
        if 'tag' in self.To:
            tag = ";tag=" + self.To['tag']

        # build ACK packet
        ack = "ACK " + self.sip_uri + " SIP/2.0\r\n"
        ack += "Via: " + self.Via[1]['protocol'] + " " + self.Via[1]['client_ip'] + \
                    ":" + self.Via[1]['client_port'] + ";rport;branch=" + self.branch + \
                    "\r\n"
        ack += "Max-Forwards: " + self.Max_Forwards + "\r\n"
        ack += "From: " + self.From['sender'] + ";tag=" + self.From['tag'] + "\r\n"
        ack += "To: " + self.To['remote_contact'] + tag + "\r\n"
        ack += "Call-ID: " + self.Call_ID + "\r\n"
        ack += "CSeq: " + str(self.CSeq - 1) + " ACK\r\n"

        # add authorization line if available
        if authorization:
            ack += authorization

        # terminate with default Content-Length of 0
        ack += self.Content_Length

        return ack


    def ack(self):
        """Register to the SIP Server"""

        # create INVITE packet
        packet = self.gen_ack(self.auth)

        # send over network
        self.write_queue.append(packet)
        self.sent_ack = True


    def gen_bye_response(self, bye_request):
        packet = "SIP/2.0 200 OK\r\n" + \
        "Via: " + bye_request['Via'] + "\r\n" + \
        "From: " + bye_request['From'] + "\r\n" + \
        "To: " + bye_request['To'] + "\r\n" + \
        "Call-ID: " + bye_request['Call-ID'] + "\r\n" + \
        "CSeq: " + bye_request['CSeq'] + "\r\n" + \
        self.Content_Length

        return packet

    def bye(self, bye_request):
        """Respond to bye"""
        packet = self.gen_bye_response(bye_request)

        self.write_queue.append(packet)
        self.destruction_callback(self)


    def parse_sdp(self, sdp):
        if not sdp:
            return None

        sdp_lines = sdp.split("\r\n")
        sdp_dict = {}

        dst_audio_addr = None
        dst_audio_port = None
        dst_video_addr = None
        dst_video_port = None
        # Huge hack to get some necessary IP and port stuff for testing
        for line in sdp_lines:
            if not line:
                continue
            key, var = line.split("=", 1)
            # sdp_dict[key] = var

            var = var.split(" ")
            if key == 'c':
                dst_audio_addr = var[2]
                dst_video_addr = var[2]
            elif key == 'm':
                if var[0] == "audio":
                    dst_audio_port = int(var[1])
                elif var[0] == "video":
                    dst_video_port = int(var[1])

        # network_type, address_type, dst_addr = sdp_dict['c'].split(" ")
        # media_description = sdp_dict['m'].split(" ")
        # dst_port = int(media_description[1])

        # return [dst_addr, dst_port]
        return (dst_audio_addr, dst_audio_port)

    def interpret(self, response):
        self.pull_server_tag(response)

        if response['Status-Line'] == "SIP/2.0 200 OK":
            self.received_200 = True
            self.ack()
            media_dst = self.parse_sdp(response['full_body'])
            if self.callback and media_dst:
                self.callback(media_dst)
        elif response['Status-Line'] == "SIP/2.0 100 Trying":
            self.received_100 = True
        elif response['Status-Line'] == "SIP/2.0 401 Unauthorized":
            self.ack()
            self.reset()
            if self.pull_nonce(response):
                self.invite()
        elif response['Status-Line'][:3] == "BYE":
            self.bye(response)
        
        print "\ncurrent state:", self.states[self.current_state], '\n\n'
