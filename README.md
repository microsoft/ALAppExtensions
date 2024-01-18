# Microsoft AL application add-ons for Microsoft Dynamics 365 Business Central
Welcome to the ALAppExtension repository!

This repo is a platform for Microsoft and our vibrant partner channel and community to work together to develop add-on apps in the AL language and to enable the general extensibility of Microsoft Dynamics 365 Business Central.

We’re working to make the core application thinner, more extensible, and easier to localize extracting business logic into add-on and localization apps. As we go, we’ll publish the source code for the apps in this repo. The apps are open for contributions and can furthermore serve as starting point for verticalizations or just as samples for developing apps.

⚠ This repository is no longer a place to develop on the System Application or Developer Tools! The System Application is now fully developed in the [BCApps](https://github.com/microsoft/BCApps) repository. Please use that repository for all contributions to the System Application and Developer Tools. ⚠

Microsoft will ship the contributions in upcoming releases of [Microsoft Dynamics 365 Business Central](https://dynamics.microsoft.com/en-us/business-central), where you’ll get to enjoy the effect of your contributions.

## Contributing

In this repository, we welcome contributions to **Microsoft's application add-ons**.

* If you are looking to contribute to the **System Application** or **Developer Tools** you can do so in the [BCApps](https://github.com/microsoft/BCApps) repository. 
* If you are looking to contribute to the **Base Application** you can do so in the [BusinessCentralApps](https://github.com/microsoft/BusinessCentralApps/) repository. Please note, that this repository is private but you can request access by filling out [this form](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbR_Qj5hjzNeNOhBcvBoRIOltUOVBVTklZN1hBOTZJUU40OE5CUzNWNk1FQy4u). 


**⚠IMPORTANT⚠:**  This is not the right place to report product defects with customer impact to Microsoft! Issues created in this repository might not get picked up by the Microsoft engineering team and issues reported in this repository do not fall under SLAs (Service Level Agreements) and hence have no guaranteed time to mitigation, just as provided fixes won't get backported to all supported versions of the product.

## Types of engagements
There are a couple of ways to engage with us here:  
  
* You can grab the code and contribute to the published apps. For more information, see the [_Contributing_](./CONTRIBUTING.md) guidelines or watch this video: [_The Contribution Process_](https://youtu.be/a1p8fTFPVwI?t=3496).
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