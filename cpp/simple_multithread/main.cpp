#include <algorithm>
#include <functional>
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

void f (const std::vector<int> &a, std::mutex &mut, unsigned int thread_num, unsigned int total_threads)
{
  size_t size = a.size () / total_threads;

  std::lock_guard<std::mutex> lock(mut);
  for (size_t i = thread_num * size; i < (thread_num + 1) * size; i++)
    std::cout << a[i] << " " << thread_num << std::endl;
}

int main ()
{
  constexpr unsigned int length = 10;
  std::vector<int> a (length);
  std::mutex mut;
  std::for_each (a.begin (), a.end (), [&] (int &x) { x = rand () % length; });

  std::thread thr1 (f, std::cref (a), std::ref(mut), 0, 2);
  std::thread thr2 (f, std::cref (a), std::ref(mut), 1, 2);
  thr1.join ();
  thr2.join ();

  return 0;
}
