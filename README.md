# Microsoft AL application foundation modules and application add-ons for Microsoft Dynamics 365 Business Central
Welcome to the ALAppExtension repository!

This repo is a platform for Microsoft and our vibrant partner channel and community to work together to develop system modules and add-on apps in the AL language and to enable the general extensibility of Microsoft Dynamics 365 Business Central.

We’re working to make the core application thinner, more extensible, and easier to localize by extracting more and more of our system logic into modules, forming a system application and application foundation, as well as extracting business logic into add-on and localization apps. As we go, we’ll publish the source code for the modules and apps in this repo. The modules and apps are open for contributions. The apps can furthermore serve as starting point for verticalizations or just as samples for developing apps.

Microsoft will ship the contributions in upcoming releases of [Microsoft Dynamics 365 Business Central](https://dynamics.microsoft.com/en-us/business-central), where you’ll get to enjoy the effect of your contributions.

## Types of engagements
There are a couple of ways to engage with us here:  
  
* You can grab the code and contribute to the published modules and apps. For more information, see the [_Contributing_](./CONTRIBUTING.md) guidelines.  
* If you’re building your own app and need something specific from us, like an event, you can help improve the general extensibility of the business logic. For more information, see the [_Extensibility requests_](#extensibility-requests) section below.


### Extensibility requests
The following are the types of requests you can submit to unblock your app:  

* Add new integration events – Get the event you need to hook-in to a process.  
* Change function visibility – For example, make a public function external or a similar change so you can call it from your extension and reuse the business logic.  
* Replace Option with Enum – Replace a specific option with an enum that supports your extension. The new type enum is extensible, but all code was written for non-extensible options.  
* Extensibility enhancements – Request changes in the application code that will improve extensibility.  
  
We’ll have a look at your request, and if we can we’ll implement it asap. If we can’t we’ll let you know and briefly explain why not. When that happens, don’t be discouraged. Go back to the drawing board, see if you can work it out, and then come back and submit another request.

### Data Collection
The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described [here](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/disable-limit-telemetry-events). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkID=824704. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Trademarks 
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.

## See Also
[FAQ](FAQ.md)

[System Application Overview](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-system-application-overview)