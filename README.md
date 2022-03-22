# Microsoft AL application foundation modules and application add-ons for Microsoft Dynamics 365 Business Central
Welcome to the ALAppExtension repository!

This repo is a platform for Microsoft and our vibrant partner channel and community to work together to develop system modules and add-on apps in the AL language and to enable the general extensibility of Microsoft Dynamics 365 Business Central.

We’re working to make the core application thinner, more extensible, and easier to localize by extracting more and more of our system logic into modules, forming a system application and application foundation, as well as extracting business logic into add-on and localization apps. As we go, we’ll publish the source code for the modules and apps in this repo. The modules and apps are open for contributions. The apps can furthermore serve as starting point for verticalizations or just as samples for developing apps.

Microsoft will ship the contributions in upcoming releases of [Microsoft Dynamics 365 Business Central](https://dynamics.microsoft.com/en-us/business-central), where you’ll get to enjoy the effect of your contributions.

## Types of engagements
There are a couple of ways to engage with us here:  
  
* You can grab the code and contribute to the published modules and apps. For more information, see the _Contributing_ section below.  
* If you’re building your own app and need something specific from us, like an event, you can help improve the general extensibility of the business logic. For more information, see the _Extensibility requests_ section below.

### Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For more contributing information, please visit [System Application Overview](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-system-application-overview).

### Extensibility requests
The following are the types of requests you can submit to unblock your app:  

* Add new integration events – Get the event you need to hook-in to a process.  
* Change function visibility – For example, make a public function external or a similar change so you can call it from your extension and reuse the business logic.  
* Replace Option with Enum – Replace a specific option with an enum that supports your extension. The new type enum is extensible, but all code was written for non-extensible options.  
* Extensibility enhancements – Request changes in the application code that will improve extensibility.  
  
We’ll have a look at your request, and if we can we’ll implement it asap. If we can’t we’ll let you know and briefly explain why not. When that happens, don’t be discouraged. Go back to the drawing board, see if you can work it out, and then come back and submit another request.

### Data Collection
The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkID=824704. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

## See Also
[FAQ](FAQ.md)

[System Application Overview](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-system-application-overview)