#include "simple_system_common.h"

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  pcount_enable(1);

  volatile float a = 1.5f;
  volatile float b = 2.0f;

  float c = a + b;
  float d = a * b;
  float e = d / c;

  pcount_enable(0);

  union {
    float f;
    uint32_t u;
  } x;

  x.f = e;

  puts("ANSWER: ");
  puthex(x.u);
  puts("\n");

  return 0;
}
