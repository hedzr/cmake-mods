#include "cmake-mods.hh"
#include <iomanip>
#include <iostream>
auto main() -> int {
	// std::cout << "Hello, World." << '\n';

	std::cout << "Hello, World!" << '\n'
	          // << "I was built by " << cmdr::cross::compiler_name() << '\n'
	          << "__cplusplus = 0x" << std::hex << std::setfill('0') << std::setw(8)
	          << __cplusplus << ' ' << '(' << std::dec << __cplusplus << ')' << '\n';

#if 0
	{
		//std::chrono::steady_clock::time_point tp;
		std::chrono::system_clock::time_point now2 = std::chrono::system_clock::now();
		using iom = cmdr::chrono::iom;
		using fmtflags = iom::fmtflags;
		std::cout << fmtflags::gmt << fmtflags::ns << "time_point (ns): os << " << now2 << '\n';
		std::cout << fmtflags::gmt << fmtflags::us << "time_point (us): os << " << now2 << '\n';
		std::cout << fmtflags::gmt << fmtflags::ms << "time_point (ms): os << " << now2 << '\n';
		std::cout << "time point of now: ";
		std::cout << now2;
		//operator<<(std::cout, now2);
		std::cout << '\n';

		auto duration = now2.time_since_epoch();
		std::cout << "duration:   os << " << duration << '\n';
		std::cout << "duration:   os << " << cmdr::chrono::format_duration(duration) << '\n';
	}
#endif
}