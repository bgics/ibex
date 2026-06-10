#include "simple_system_common.h"

volatile float result;

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  pcount_enable(1);

  const int N = 10000;
  const float dx = 1.0f / N;

  float sum = 0.0f;

  for (int i = 0; i < N; i++) {
    float x = (i + 0.5f) * dx;
    sum += 4.0f / (1.0f + x * x);
  }

  result = sum * dx;

  pcount_enable(0);

  union {
    float f;
    uint32_t u;
  } x;

  x.f = result;

  puts("ANSWER: ");
  puthex(x.u);
  puts("\n");

  return 0;
}
