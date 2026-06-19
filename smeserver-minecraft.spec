%define name smeserver-minecraft
%define version 1.0
%define release 2
Summary: This is what minecraft does.
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
Source: %{name}-%{version}.tar.gz
License: GNU GPL version 2
Group: SMEserver/addon
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}
BuildArchitectures: noarch
BuildRequires: smeserver-devtools
Requires: smeserver-release >= 11.0
Requires: jq rsync screen wget zip sudo
Requires: java-17-openjdk
Requires: java-11-openjdk
Requires: java-21-openjdk
Requires: java-latest-openjdk
AutoReqProv: no

%description
this is a wrapper to install msm hq and manage your minecraft server.

%changelog
* Fri Jun 19 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.0-2.sme
- add fabric  folia  leaf  leaves  minecraft  paper  purpur  quilt  spigot support
- get java 11, 17, 21, 26

* Sun Jun 14 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.0-1.sme
- initial code based on Commit 7a9d120
- buildTools.jar added from spigot
- set java17 as default path
- set 2560M as default ram
- fix config set [MSM 371] 
- disable auto update as we fixed few things, prevents regression 

%prep

%setup -q

%build
perl createlinks

%install
rm -rf $RPM_BUILD_ROOT
(cd root   ; find . -depth -print | cpio -dump $RPM_BUILD_ROOT)
rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT \
  --dir /opt/msm 'attr(755,minecraft,minecraft)' \
  --file /etc/msm.conf 'attr(755,minecraft,minecraft)'\
  --file /usr/bin/msm  'attr(755,root,root)'\
> %{name}-%{version}-filelist
#echo "%doc COPYING"  >> %{name}-%{version}-filelist
#--dir <dir> 'attr(755,user,grp)' \
#--file <file> 'attr(755,root,root)' \

%clean
cd ..
rm -rf %{name}-%{version}

%pre
grep '^minecraft:' /etc/passwd > /dev/null || \
/usr/sbin/useradd -c "minecraft" -M -d /opt/msm   -s /bin/bash minecraft

%preun

%post

%postun
#uninstall
%files -f %{name}-%{version}-filelist
%defattr(-,root,root)
