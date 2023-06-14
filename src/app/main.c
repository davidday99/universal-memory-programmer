#include "app/rpc_server.h"

static struct rpc_Server Server;
static struct rpc_Server *ServerPtr = &Server;

int main() {
    // chip init
    
    rpc_ServerInit(ServerPtr);

    while (1) {
        rpc_ServerTick(ServerPtr);
    }
}


