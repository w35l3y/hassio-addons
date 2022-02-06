# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][keepachangelog],
and this project adheres to [Semantic Versioning][semver].

## [1.0.4] - 2022-02-06

### Added

- Added new types of messages (location, attachment, buttons, sections)
- Added event that is sent whenever a message is received

## [1.0.3] - 2022-02-04

### Changed

- No need to long-lived access token anymore (Now it is using internal communication)

## [1.0.2] - 2022-02-03

### Added

- Works on x86_64 architecture

### Changed

- Chat Ids in the Notification bar

## [1.0.1] - 2022-02-02

### Changed

- QR Code in the Notification bar

### Removed

- Ingress for accessing QR Code

[semver]: https://semver.org/spec/v2.0.0.html
[keepachangelog]: https://keepachangelog.com/en/1.0.0/
