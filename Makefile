.PHONY: all archlinux debian-stable debian-testing fedora fedora-32 fedora-rawhide ubuntu \
        dockerbuild dockerbuildandtest \
        archlinux-cxx14 archlinux-cxx17-release archlinux-clang archlinux-clang-cxx14 \
        archlinux-clang-cxx17-release archlinux-clang-cxx20-release archlinux-clang-release \
        debian-stable-release debian-stable-cross-compilation-for-arm \
        debian-testing-clang-main \
        fedora-with-leda fedora-release fedora-strict-ansi \
        fedora-32-release \
        fedora-rawhide-release \
        ubuntu-cxx11 ubuntu-no-deprecated-code ubuntu-no-gmp-no-leda ubuntu-gcc6 \
        ubuntu-gcc6-cxx1z ubuntu-gcc6-release ubuntu-gcc_master_cxx20-release

all: archlinux archlinux-cxx14 archlinux-cxx17-release archlinux-clang archlinux-clang-cxx14 \
     archlinux-clang-cxx17-release archlinux-clang-cxx20-release archlinux-clang-release \
     debian-stable debian-stable-release debian-stable-cross-compilation-for-arm \
     debian-testing debian-testing-clang-main \
     fedora fedora-with-leda fedora-release fedora-strict-ansi \
     fedora-32 fedora-32-release \
     fedora-rawhide fedora-rawhide-release \
     ubuntu ubuntu-cxx11 ubuntu-no-deprecated-code ubuntu-no-gmp-no-leda ubuntu-gcc6 \
     ubuntu-gcc6-cxx1z ubuntu-gcc6-release ubuntu-gcc_master_cxx20-release

archlinux: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux DIR=ArchLinux

archlinux-cxx14: archlinux | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-cxx14 DIR=ArchLinux-CXX14

archlinux-cxx17-release: archlinux
	$(MAKE) dockerbuildandtest TARGET=archlinux-cxx17-release DIR=ArchLinux-CXX17-Release

archlinux-clang: archlinux | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-clang DIR=ArchLinux-clang

archlinux-clang-cxx14: archlinux-clang | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-clang-cxx14 DIR=ArchLinux-clang-CXX14

archlinux-clang-cxx17-release: archlinux-clang | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-clang-cxx17-release DIR=ArchLinux-clang-CXX17-Release

archlinux-clang-cxx20-release: archlinux-clang | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-clang-cxx20-release DIR=ArchLinux-clang-CXX20-Release

archlinux-clang-release: archlinux-clang | download_cgal
	$(MAKE) dockerbuildandtest TARGET=archlinux-clang-release DIR=ArchLinux-clang-Release

debian-stable: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=debian-stable DIR=Debian-stable

debian-stable-release: debian-stable | download_cgal
	$(MAKE) dockerbuildandtest TARGET=debian-stable-release DIR=Debian-stable-Release

debian-stable-cross-compilation-for-arm: debian-stable | download_cgal
	$(MAKE) dockerbuildandtest TARGET=debian-stable-cross-compilation-for-arm DIR=Debian-stable-cross-compilation-for-arm

debian-testing: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=debian-testing DIR=Debian-testing

debian-testing-clang-main: debian-testing | download_cgal
	$(MAKE) dockerbuildandtest TARGET=debian-testing-clang-main DIR=Debian-testing-clang-main

fedora: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora DIR=Fedora

fedora-with-leda: fedora | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-with-leda DIR=Fedora-with-LEDA

fedora-release: fedora | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-release DIR=Fedora-Release

fedora-strict-ansi: fedora | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-strict-ansi DIR=Fedora-strict-ansi

fedora-32: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-32 DIR=Fedora-32

fedora-32-release: fedora-32 | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-32-release DIR=Fedora-32-Release

fedora-rawhide: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-rawhide DIR=Fedora-rawhide

fedora-rawhide-release: fedora-rawhide | download_cgal
	$(MAKE) dockerbuildandtest TARGET=fedora-rawhide-release DIR=Fedora-rawhide-Release

ubuntu: | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu DIR=Ubuntu

ubuntu-cxx11: ubuntu | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-cxx11 DIR=Ubuntu-CXX11

ubuntu-no-deprecated-code: ubuntu | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-no-deprecated-code DIR=Ubuntu-NO_DEPRECATED_CODE

ubuntu-no-gmp-no-leda: ubuntu | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-no-gmp-no-leda DIR=Ubuntu-no-gmp-no-leda

ubuntu-gcc6: ubuntu | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-gcc6 DIR=Ubuntu-GCC6

ubuntu-gcc6-cxx1z: ubuntu-gcc6 | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-gcc6-cxx1z DIR=Ubuntu-GCC6-CXX1Z

ubuntu-gcc6-release: ubuntu-gcc6 | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-gcc6-release DIR=Ubuntu-GCC6-Release

ubuntu-gcc_master_cxx20-release: ubuntu-gcc6 | download_cgal
	$(MAKE) dockerbuildandtest TARGET=ubuntu-gcc_master_cxx20-release DIR=Ubuntu-GCC_master_cpp20-Release

download_cgal:
	@CGAL_TARBALL=$$(curl -s https://api.github.com/repos/CGAL/cgal/releases/latest | jq -r .tarball_url); \
	echo "::group::Download and extract CGAL tarball from $$CGAL_TARBALL"; \
	curl -o cgal.tar.gz -L "$$CGAL_TARBALL";
	mkdir -p cgal;
	tar -xzf cgal.tar.gz -C cgal --strip-components=1;
	find cgal -name 'CMakeLists.txt' | xargs grep -l "find_package(Eigen3 3.1.0 REQUIRED)"  | xargs sed -i 's/find_package(Eigen3 3.1.0 REQUIRED)/find_package(Eigen3 3.1.0 QUIET)/'
	if command -v selinuxenabled >/dev/null && selinuxenabled; then \
	  chcon -Rt container_file_t cgal; \
	fi;
	@echo '::endgroup::'

dockerbuild:
	if [ -n "$$GITHUB_SHA" ]; then \
	  COMMIT_URL=https://github.com/$${GITHUB_REPOSITORY}/blob/$${GITHUB_SHA}; \
	fi; \
	docker build --build-context root=. --build-arg dockerfile_url=$${COMMIT_URL}/$(DIR)/Dockerfile --build-arg image_tag=cgal/testsuite-docker:$(TARGET) -t cgal/testsuite-docker:$(TARGET) ./$(DIR);

dockerbuildandtest: dockerbuild
	@echo "::group::Build image $(TARGET) from $(DIR)/Dockerfile";
	$(MAKE) dockerbuild TARGET=$(TARGET) DIR=$(DIR);
	@echo '::endgroup::';
	@echo "::group::Display third-party libraries of $(TARGET)";
	docker run --rm -v $$(pwd)/cgal:/cgal cgal/testsuite-docker:$(TARGET) cmake -S /cgal -B /build -DCGAL_TEST_SUITE=ON -DCMAKE_DISABLE_FIND_PACKAGE_libpointmatcher=ON
	@echo "::endgroup::"
	@echo "::group::Test image $(TARGET)";
	docker run --rm -v $$(pwd)/cgal:/cgal cgal/testsuite-docker:$(TARGET) bash -c 'cmake -DCMAKE_DISABLE_FIND_PACKAGE_libpointmatcher=ON -DWITH_examples=ON -S /cgal -B /build && cmake --build /build -t terrain -v';
	@echo '::endgroup::'
