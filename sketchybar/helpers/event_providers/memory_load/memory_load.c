#include <mach/mach.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "../sketchybar.h"

static uint64_t get_total_memory() {
  uint64_t total;
  size_t size = sizeof(total);
  sysctlbyname("hw.memsize", &total, &size, NULL, 0);
  return total;
}

static float get_used_memory_gb(uint64_t total_bytes, float *percent_out) {
  vm_statistics64_data_t vm_stat;
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  host_statistics64(mach_host_self(), HOST_VM_INFO64,
                    (host_info64_t)&vm_stat, &count);

  uint64_t page_size = getpagesize();
  uint64_t used_pages = vm_stat.active_count + vm_stat.wire_count;
  uint64_t used_bytes = used_pages * page_size;

  *percent_out = (float)used_bytes / (float)total_bytes * 100.0f;
  return (float)used_bytes / (1024.0f * 1024.0f * 1024.0f);
}

int main(int argc, char **argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);

  uint64_t total_bytes = get_total_memory();
  float total_gb = (float)total_bytes / (1024.0f * 1024.0f * 1024.0f);

  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  char trigger_message[512];
  for (;;) {
    float percent = 0.0f;
    float used_gb = get_used_memory_gb(total_bytes, &percent);

    snprintf(trigger_message, 512,
             "--trigger '%s' used_gb='%.1f' total_gb='%.0f' load='%d'",
             argv[1],
             used_gb,
             total_gb,
             (int)percent);

    sketchybar(trigger_message);
    usleep(update_freq * 1000000);
  }
  return 0;
}
