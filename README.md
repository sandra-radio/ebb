## Ebb

https://ebb.radio/

Providing radio mail flow statistics within Winlink RMSes (Radio Mail Server)

## Goals

1. Provide visual representations around the flow of mail within Winlink so users know how active
   a given RMS is.
2. Act as a mailable service for Winlink users in the field to query about other stations.

## Status

The heatmap has about a dozen RMSes that are being tracked over a 2 week period, updated hourly.
There is currently no mailable tactile callsign for Ebb within the winlink system and the
functionality has not be written to reply to mail queries.

## Why

Initially when I got started with winlink there wasnt much I could find in regards to the various
statuses of RMSes near my grid square. The [Winlink RMS List](https://www.winlink.org/RMSChannels)
provides a simple RMS status but it doesnt account for actual mail flowing through the system. It
simply provides a status that the RMS can reach the CMS (Central Messaging Server). I had a few
issues with a local station where it was reporting to Winlink as "Up" but the actual radio was
having issues and no client would connect. I thought it would be really helpful to be able to
track the flow of mail through a given RMS. This would help immensely in troubleshooting.

Additionally, I have found my self on many hikes without internet or cell coverage. Given the proximity
to my QTH and one known good RMS, it would be helpful to see the status of other RMSes via radio mail.

## Deployment

Currently running `NixOS 23.11` on a Hetzner VPS in the DC: `hil-dc1`
