#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>

int
main(int argc, char **argv)
{
  int inp = 0;
  char buf[1024];
  ssize_t len, idx = 0;
  ssize_t start=0, end=-1;

  for (ssize_t pos=0; ; pos += len) {
    len = read(inp, buf, sizeof(buf));
    if (len > 0) {
      int i, j;
      for (i=0; i< len; i = j + 1) {
        for (j=i; j<len && buf[j]; j++);
        if (i < j) {
         // nop
        }
        if (j < len) {
          end = pos + j;
          printf("#%zd@%zd(%zd)\n", idx, start, end + 1 - start);
          start = end + 1;
          idx++;
        }
      }
    } else if (len == 0) {
      if (pos > start) {
        printf("#%zd@%zd(%zd)\n", idx, start, pos - start);
        idx++;
      }
      close(inp);
      break;
    } else {
      perror("read");
      return 1;
    }
  }

  return 0;
}
