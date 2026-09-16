# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.6] - 2026-09-16

### Changed

- Upgraded the OTel collector image from `0.150.1` to `0.161.0`. One upstream behaviour change
  comes with it: the Azure Resource Logs translator now emits the v1 semconv attribute
  `exception.message` instead of the deprecated `error.message`, following the promotion of the
  `extension.azureencoding.DontEmitV0LogConventions` and `extension.azureencoding.EmitV1LogConventions`
  feature gates to beta ([#50885](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/50885)).
- Renamed the `resourcedetection` processor to `resource_detection` in the generated collector
  config, following its upstream rename in `0.153.0` ([#48525](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/48525)).

## [1.0.5] - 2026-09-01

### Changed

- Update the AzureRM provider constraint to `~> 4.0`.

## [1.0.4] - 2026-04-24

Releases up to and including v1.0.4 predate this changelog. See the
[GitHub releases](https://github.com/tsuga-dev/terraform-azurerm-tsuga-ingestion/releases) for their contents.
