# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rpm multilib

DESCRIPTION="Intel's implementation of the OpenCL standard"
HOMEPAGE="http://software.intel.com/en-us/articles/opencl-sdk/"
SRC_URI="http://registrationcenter.intel.com/irc_nas/5193/opencl_runtime_15.1_x64_5.0.0.57.tgz"
LICENSE="Intel-SDP"
SLOT="0"
IUSE="+system-tbb system-clang"
KEYWORDS="-* ~amd64"
RESTRICT="mirror"

RDEPEND="app-eselect/eselect-opencl
	sys-process/numactl
	system-tbb? ( >=dev-cpp/tbb-4.2.20131118 )
	system-clang? ( =sys-devel/clang-3.7* )
	"
DEPEND=""

S=${WORKDIR}/opencl_runtime_15.1_x64_${PV}/rpm/
INTEL_CL=opt/intel/opencl-1.2-${PV}
INTEL_VENDOR_DIR=usr/$(get_libdir)/OpenCL/vendors/intel/

QA_PREBUILT="${INTEL_OCL}/*"

src_unpack() {
	default

	cd ${S}

	PKGS="base intel-cpu"

	for PKG in ${PKGS}; do
		FILENAME="opencl-1.2-${PKG}-5.0.0.57-1.x86_64.rpm"
		einfo "Extracting \"${FILENAME}\"..."
		rpm_unpack ./"$FILENAME" || die
	done

	mv opt ${WORKDIR}
}

src_prepare() {
	# Remove bundled stuff
	if use system-clang; then
		rm -f "${WORKDIR}/${INTEL_CL}"/lib64/libclang*
	fi
	if use system-tbb; then
		rm -f "${WORKDIR}/${INTEL_CL}"/lib64/libtbb*
	fi
}

src_install() {
	insinto /etc/OpenCL/vendors/
	doins "${WORKDIR}/${INTEL_CL}"/etc/intel64.icd

	insinto /"${INTEL_CL}"/lib64
	insopts -m 755
	doins "${WORKDIR}/${INTEL_CL}"/lib64/*

#	insinto /"${INTEL_CL}"/bin
#	doins "${WORKDIR}"/"${INTEL_CL}"/bin/*

	# TODO put this somewhere
	# doins ${INTEL_CL}/eclipse-plug-in/OpenCL_SDK_0.1.0.jar

	dodir "${INTEL_VENDOR_DIR}"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so"     "${INTEL_VENDOR_DIR}/libOpenCL.so"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so.1"   "${INTEL_VENDOR_DIR}/libOpenCL.so.1"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so.1.2" "${INTEL_VENDOR_DIR}/libOpenCL.so.1.2"
}

pkg_postinst() {
	eselect opencl set --use-old intel
}
