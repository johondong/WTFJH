#import "../SharedDefine.pch"
#import <sys/socket.h>
#import <arpa/inet.h>
/*

int	getpeername(int, struct sockaddr * __restrict, socklen_t * __restrict)
		__DARWIN_ALIAS(getpeername);
int	getsockname(int, struct sockaddr * __restrict, socklen_t * __restrict)
		__DARWIN_ALIAS(getsockname);
int	getsockopt(int, int, int, void * __restrict, socklen_t * __restrict);
     ssize_t
     recvfrom(int socket, void *restrict buffer, size_t length, int flags,
         struct sockaddr *restrict address, socklen_t *restrict address_len);

     ssize_t
     recvmsg(int socket, struct msghdr *message, int flags);


     ssize_t
     send(int socket, const void *buffer, size_t length, int flags);

     ssize_t
     sendmsg(int socket, const struct msghdr *message, int flags);

     ssize_t
     sendto(int socket, const void *buffer, size_t length, int flags,
         const struct sockaddr *dest_addr, socklen_t dest_len);
int	setsockopt(int, int, int, const void *, socklen_t);
int	shutdown(int, int);
int	sockatmark(int);
int	socketpair(int, int, int, int *) __DARWIN_ALIAS(socketpair);
int	sendfile(int, int, off_t, off_t *, struct sf_hdtr *, int);

void	pfctlinput(int, struct sockaddr *);
int connectx(int , const sa_endpoints_t *, sae_associd_t, unsigned int,
    const struct iovec *, unsigned int, size_t *, sae_connid_t *);
int disconnectx(int , sae_associd_t, sae_connid_t);*/

static NSString* get_ip_str(const struct sockaddr *sa)
{
	int maxlen=SOCK_MAXADDRLEN;
	char* s=(char*)malloc(SOCK_MAXADDRLEN);
	//Shamefully Borrowed from http://beej.us/guide/bgnet/output/html/multipage/inet_ntopman.html
    switch(sa->sa_family) {
        case AF_INET:
            inet_ntop(AF_INET, &(((struct sockaddr_in *)sa)->sin_addr),
                    s, maxlen);
            break;

        case AF_INET6:
            inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr),
                    s, maxlen);
            break;

        default:
            s=NULL;
    }

   if(s!=NULL){
   		return [NSString stringWithUTF8String:s];
   }
   else{
   	return @"WTFJH-Unsupported sa_family";
   }
}


//Old Pointers
int (*old_socket)(int domain, int type, int protocol);
int	(*old_accept)(int, struct sockaddr * __restrict, socklen_t * __restrict);
int	(*old_bind)(int, struct sockaddr *, socklen_t);
int	(*old_connect)(int, const struct sockaddr *, socklen_t);
int	(*old_listen)(int, int);
ssize_t (*old_recv)(int socket, void *buffer, size_t length, int flags);

//New Functions
int new_socket(int domain, int type, int protocol){
	int descriptor=old_socket(domain,type,protocol);
	if(WTShouldLog){
		WTInit(@"Socket",@"socket");
		WTAdd([NSNumber numberWithInt:domain],@"Domain");
		WTAdd([NSNumber numberWithInt:type],@"Type");
		WTAdd([NSNumber numberWithInt:protocol],@"Protocol");
		WTReturn([NSNumber numberWithInt:descriptor]);
		WTSave;
		WTRelease;

	}
return descriptor;

}
int	new_accept(int newFileDesc, struct sockaddr * addr, socklen_t * addrlength){
	int retVal=0;
	if(WTShouldLog){
		WTInit(@"Socket",@"accept");
		WTAdd([NSNumber numberWithInt:newFileDesc],@"NewFileDescriptor");
		WTAdd([NSNumber numberWithUnsignedInt:addr->sa_len],@"SocketAddressTotalLength");
		WTAdd([NSNumber numberWithUnsignedShort:addr->sa_family],@"SocketAddressAddressFamily");
		WTAdd(get_ip_str(addr),@"Address");
		WTAdd([NSNumber numberWithUnsignedShort:*addrlength],@"SocketAddressLength");

		retVal=old_accept(newFileDesc,addr,addrlength);
		WTReturn([NSNumber numberWithInt:retVal]);
		WTSave;
		WTRelease;

	}
	else{
	retVal=old_accept(newFileDesc,addr,addrlength);
	}

	return retVal;
}
int	new_bind(int A, struct sockaddr * addr, socklen_t addrlength){
	int retVal=0;
	if(WTShouldLog){
		WTInit(@"Socket",@"bind");
		WTAdd([NSNumber numberWithUnsignedInt:addr->sa_len],@"SocketAddressTotalLength");
		WTAdd([NSNumber numberWithUnsignedShort:addr->sa_family],@"SocketAddressAddressFamily");
		WTAdd(get_ip_str(addr),@"Address");
		WTAdd([NSNumber numberWithUnsignedShort:addrlength],@"SocketAddressLength");
		retVal=old_bind(A,addr,addrlength);
		WTReturn([NSNumber numberWithInt:retVal]);
		WTSave;
		WTRelease;

	}
	else{
		retVal=old_bind(A,addr,addrlength);
	}
	return retVal;

}
int	new_connect(int sockfd, const struct sockaddr *addr,
                   socklen_t addrlen){
	int retVal=0;
	if(WTShouldLog){
		WTInit(@"Socket",@"connect");
		WTAdd([NSNumber numberWithUnsignedShort:sockfd],@"SocketFileDescriptor");
		WTAdd([NSNumber numberWithUnsignedInt:addr->sa_len],@"SocketAddressTotalLength");
		WTAdd([NSNumber numberWithUnsignedShort:addr->sa_family],@"SocketAddressAddressFamily");
		WTAdd(get_ip_str(addr),@"Address");
		WTAdd([NSNumber numberWithUnsignedShort:addrlen],@"SocketAddressLength");
		retVal=old_connect(sockfd,addr,addrlen);
		WTReturn([NSNumber numberWithInt:retVal]);
		WTSave;
		WTRelease;

	}
	else{
		retVal=old_connect(sockfd,addr,addrlen);
	}
	return retVal;


}
int	new_listen(int sockfd, int backlog){
	int retVal=0;
	if(WTShouldLog){
		WTInit(@"Socket",@"listen");
		WTAdd([NSNumber numberWithUnsignedInt:sockfd],@"SocketFileDescriptor");
		WTAdd([NSNumber numberWithUnsignedInt:backlog],@"BackLog");
		retVal=old_listen(sockfd,backlog);
		WTReturn([NSNumber numberWithInt:retVal]);
		WTSave;
		WTRelease;

	}
	else{
		retVal=old_listen(sockfd,backlog);
	}
	return retVal;
}
ssize_t new_recv(int socket, void *buffer, size_t length, int flags){
	ssize_t retVal=0;
	if(WTShouldLog){
		retVal=old_recv(socket,buffer,length,flags);
		WTInit(@"Socket",@"recv");
		WTAdd([NSNumber numberWithUnsignedInt:socket],@"SocketFileDescriptor");
		WTAdd([NSData dataWithBytes:buffer length:length],@"Data");
		WTAdd([NSNumber numberWithInt:flags],@"Flags");
		WTReturn([NSNumber numberWithLong:retVal]);
		WTSave;
		WTRelease;

	}
	else{
		retVal=old_recv(socket,buffer,length,flags);
	}
	return retVal;
}
extern void init_Socket_hook() {
    WTHookFunction((void*)socket,(void*)new_socket, (void**)&old_socket);
    WTHookFunction((void*)accept,(void*)new_accept, (void**)&old_accept);
    WTHookFunction((void*)bind,(void*)new_bind, (void**)&old_bind);
    WTHookFunction((void*)connect,(void*)new_connect, (void**)&old_connect);
    WTHookFunction((void*)listen,(void*)new_listen, (void**)&old_listen);
    WTHookFunction((void*)recv,(void*)new_recv, (void**)&old_recv);
}
