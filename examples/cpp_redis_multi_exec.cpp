// The MIT License (MIT)

#if _WIN32
#include "winsock_initializer.h"
#endif
#include <cpp_redis/cpp_redis>
#include <string>

int
main(void) {
#if _WIN32
  winsock_initializer winsock_init;
#endif
  cpp_redis::client client;

  client.connect("127.0.0.1", 6379,
    [](const std::string& host, std::size_t port, cpp_redis::connect_state status) {
      if (status == cpp_redis::connect_state::dropped) {
        std::cout << "client disconnected from " << host << ":" << port << std::endl;
      }
    });
  client.multi([](cpp_redis::reply& reply) {
    std::cout << "transaction start:" << reply << std::endl;
  });
  client.set("hello", "42", [](cpp_redis::reply& reply) {
    std::cout << "set hello 42: " << reply << std::endl;
  });
  client.decrby("hello", 12, [](cpp_redis::reply& reply) {
    std::cout << "decrby hello 12: " << reply << std::endl;
  });
  // Previous two commands will be queued until exec called
  client.exec([](cpp_redis::reply& reply) {
    std::cout << "transaction end:" << reply << std::endl;
  });

  client.sync_commit();

  return 0;
}
