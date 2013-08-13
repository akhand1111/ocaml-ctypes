#ifndef TEST_FUNCTIONS_H
#define TEST_FUNCTIONS_H

struct padded_struct {
  char padding[1];
  int i;
  char more_padding[3];
  int j;
  char tail_padding[33];
};

#endif /* TEST_FUNCTIONS_H */
