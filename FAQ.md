# Frequently asked questions

## What is this repository for now?

This repository is solely for Business Central extensibility requests. Use it when you need Microsoft to add an event, make a function external, replace an option with an extensible enum, or make another extensibility change that helps unblock your app.

## Can I submit code contributions or pull requests here?

No. ALAppExtensions no longer accepts new pull requests or application-code contributions. Use [BCApps](https://github.com/microsoft/BCApps) for Business Central application contributions.

## How do I create a good extensibility request?

Search existing issues first to avoid duplicates. Then use the extensibility request issue template and explain the business scenario, what you need to extend, and why the current application does not let you do it.

For more guidance, see [Create extensibility requests for Microsoft Dynamics 365 Business Central](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/create-extensibility-request).

## What kinds of extensibility requests are accepted?

- **Event-request:** Request a new integration event.
- **Request-for-external:** Request that a function is made external or otherwise callable from an extension.
- **Enum-request:** Request that an option is replaced with an extensible enum.
- **Extensibility-enhancement:** Request a broader change that improves extensibility.
- **Extensibility-bug:** Request a small fix to unblock an extensibility scenario.

## When will my request ship?

Accepted requests are generally delivered in a future Business Central update. Event requests may ship in a next minor update, while larger extensibility changes are usually considered for future major releases. Backporting is handled case by case and depends on impact, risk, and whether the request is blocking.

## Where should I report other things?

- **Product defects or customer-impacting issues:** Use [Business Central support](https://aka.ms/bcsupport).
- **Product ideas:** Use [BC Ideas](https://aka.ms/bcideas).
- **AL compiler or developer tooling suggestions:** Use [microsoft/AL](https://github.com/microsoft/AL/issues).
