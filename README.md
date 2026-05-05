# Business Central extensibility requests
Welcome to the ALAppExtension repository!

This repository is now solely for extensibility requests for Microsoft Dynamics 365 Business Central.

It is no longer a place to contribute to Microsoft AL application add-ons. New pull requests are no longer accepted in this repository.

⚠ This repository is no longer a place to develop the Business Central application platform! The application is now fully developed in the [BCApps](https://github.com/microsoft/BCApps) repository. Please use that repository for all contributions. ⚠

## Contributing

This repository no longer accepts new pull requests for Microsoft's application add-ons. Please only create issues for extensibility requests, such as event requests, requests to make functions external, enum requests, or other extensibility enhancements.

* If you are looking to contribute code to the business application, you can do so in the [BCApps](https://github.com/microsoft/BCApps) repository. 

**⚠IMPORTANT⚠:**  This is not the right place to report product defects with customer impact to Microsoft! Issues created in this repository might not get picked up by the Microsoft engineering team and issues reported in this repository do not fall under SLAs (Service Level Agreements) and hence have no guaranteed time to mitigation, just as provided fixes won't get backported to all supported versions of the product.

## Types of engagements
There is one way to engage with us here:

* If you’re building your own app and need something specific from us, like an event, a function visibility change, or another extensibility enhancement, you can help improve the general extensibility of the business logic. For more information, see the [_Extensibility requests_](#extensibility-requests) section below.


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
