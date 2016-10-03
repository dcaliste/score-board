# RPM spec file for Score-board.
# This file is used to build Redhat Package Manager packages for
# Maep.  Such packages make it easy to install and uninstall
# the library and related files from binaries or source.
#
# RPM. To build, use the command: rpmbuild --clean -ba maep-qt.spec
#

Name: harbour-score-board

Summary: A Sailfish application to store scores from games (or not)
Version: 1.1.0
Release: 1
License: GPLv3
Source: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Requires: sailfishsilica-qt5
Requires: libsailfishapp-launcher

%description
A Sailfish application to store scores from games (or not). It
automatically saves previous boards, and they can be modified
later. It allows to create boards up to ten players or teams and
can display the summation of all scores.

%prep
rm -rf $RPM_BUILD_ROOT
%setup -q -n %{name}-%{version}

%install
rm -rf %{buildroot}
install -d %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/About.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/harbour-score-board.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/RowHeader.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/RowEditor.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/RowItem.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/ScoreModel.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/TeamModel.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/Score.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/BoardSetup.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/FavTeam.qml %{buildroot}%{_datadir}/%{name}/qml
install -m 644 -p qml/sqlite_backend.js %{buildroot}%{_datadir}/%{name}/qml
install -d %{buildroot}%{_datadir}/%{name}
install -m 644 -p about-score-board.png %{buildroot}%{_datadir}/%{name}
install -d %{buildroot}%{_datadir}/icons/hicolor/86x86/apps/
install -m 644 -p harbour-score-board-86.png %{buildroot}%{_datadir}/icons/hicolor/86x86/apps/harbour-score-board.png
install -d %{buildroot}%{_datadir}/icons/hicolor/108x108/apps/
install -m 644 -p harbour-score-board-108.png %{buildroot}%{_datadir}/icons/hicolor/108x108/apps/harbour-score-board.png
install -d %{buildroot}%{_datadir}/icons/hicolor/128x128/apps/
install -m 644 -p harbour-score-board-128.png %{buildroot}%{_datadir}/icons/hicolor/128x128/apps/harbour-score-board.png
install -d %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/
install -m 644 -p harbour-score-board-256.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/harbour-score-board.png
install -d %{buildroot}%{_datadir}/applications
install -m 644 -p harbour-score-board.desktop %{buildroot}%{_datadir}/applications

%files
%defattr(-,root,root,-)
%{_datadir}/applications
%{_datadir}/icons
%{_datadir}/%{name}

%changelog
* Sun Oct 03 2016 - Damien Caliste <dcaliste@free.fr> 1.1.0-1
- Add multi resolution icons.
- Add favorite names as context menu when editing board.
- Allow to tap on board header to go to the editing page.
- Add a favorite board setup page to define default board setup.

* Fri Aug 28 2015 - Damien Caliste <dcaliste@free.fr> 1.0.0-1
- initial release with basic functionalities.
