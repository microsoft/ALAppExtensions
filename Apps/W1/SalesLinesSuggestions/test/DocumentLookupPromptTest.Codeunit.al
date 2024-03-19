namespace Microsoft.Sales.Document.Test;
codeunit 139784 "Document Lookup Prompt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Document Lookup] [Prompt] 
    end;

    var
        // Sales Order
        SalesOrderPrompt01Lbl: Label 'Need all the items from previous sales order';
        SalesOrderPrompt02Lbl: Label 'Need all the items from sales order SO12345';
        SalesOrderPrompt03Lbl: Label 'Need 5 loud speaker from sales order';
        SalesOrderPrompt04Lbl: Label 'Need 5 loud speaker from sales order SO12345';
        SalesOrderPrompt05Lbl: Label 'Need all the items from sales order from last week to today';
        SalesOrderPrompt06Lbl: Label 'Need 5 loud speaker from sales order from last week to today';
        SalesOrderPrompt07Lbl: Label 'Need all the items from sales order on 2023-01-01';
        SalesOrderPrompt08Lbl: Label 'Need all the items from sales order on last February 1st';
        // Magic function test: date in future
        SalesOrderPrompt09Lbl: Label 'Need all the items from sales order on next week';
        // Magic function test: date in future
        SalesOrderPrompt10Lbl: Label 'Need all the items from sales order from last month to next week';
        SalesOrderPrompt11Lbl: Label 'Hi Simon, hope you''re doing well. I was reviewing some of our sales data and realized I need a bit more information. Could you retrieve the top 3 bestselling items from one of our recent sales orders? The order number, if I''m not mistaken, should be 54321. This information will be crucial for our upcoming marketing strategy meeting. Thanks a lot for your help on this!';
        SalesOrderPrompt12Lbl: Label 'Hey there! I need a small favor. Can you select only the blue widgets from sales order 67890? It''s for a client-specific request. Thanks!';
        SalesOrderPrompt13Lbl: Label 'Hello! Quick task: could you list all items exceeding $1000 in value from sales order 13579? It''s important for our high-value sales analysis. Appreciate your help!';
        SalesOrderPrompt14Lbl: Label 'Hi! Can you gather all electronic items from sales orders yesterday? Need to check our electronic goods turnover. Thanks a lot!';
        SalesOrderPrompt15Lbl: Label 'Good day! Please collect all perishable goods from sales order SO24680. We need to ensure they''re processed quickly. Thank you!';
        SalesOrderPrompt16Lbl: Label 'Hello! Quick request: filter out all items under 5 lbs from sales order SO11111 for our lightweight items inventory. Thanks!';
        SalesOrderPrompt17Lbl: Label 'Hi! Can you identify the custom-made items in the sales order from 2023-05-05? It''s for a custom order follow-up. Much appreciated!';
        SalesOrderPrompt18Lbl: Label 'Hey, can you show me the items with warranty from sales orders before last Christmas? Need to review our warranty coverage. Thanks!';
        SalesOrderPrompt19Lbl: Label 'Hi there! Need your help to find all out-of-stock items from sales order SO22222 for restocking purposes. Thanks a bunch!';
        SalesOrderPrompt20Lbl: Label 'Hello! Could you locate all items shipped to New York in sales order SO33333? It''s for a regional sales analysis. Thank you!';
        SalesOrderPrompt21Lbl: Label 'Good day! Please detail the items with serial numbers from the sales order on 2023-02-14 for our inventory records. Thanks!';
        SalesOrderPrompt22Lbl: Label 'Hi! Can you extract all discounted items from sales orders ISOD2012345512? It''s for a discount performance review. Much appreciated!';
        SalesOrderPrompt23Lbl: Label 'Hey there! Need a quick hand isolating fragile items from sales order SO44444 for special packaging. Thanks in advance!';
        SalesOrderPrompt24Lbl: Label 'Hello! Could you do a quick review of items from recent sales orders? Just a general stock check. Thanks!';
        SalesOrderPrompt25Lbl: Label 'Hi! Please highlight all red-colored items from sales order SO55555. It''s for a color trend analysis. Thank you!';
        SalesOrderPrompt26Lbl: Label 'Good day! Can you summarize all items for office use from recent sales orders? Need it for office inventory assessment. Thanks!';
        SalesOrderPrompt27Lbl: Label 'Hey! Can you pinpoint all eco-friendly items from our sales orders? It''s for our sustainability report. Much appreciated!';
        SalesOrderPrompt28Lbl: Label 'Hi there! Please enumerate all bulk items from sales order SO66666. We''re assessing our bulk sales strategy. Thank you!';
        SalesOrderPrompt29Lbl: Label 'Hello! Need a quick list of items with express delivery in sales order SO77777 for our delivery efficiency review. Thanks!';
        SalesOrderPrompt30Lbl: Label 'Hey! Can you assess the items receiving 5-star reviews from our previous sales order? I need them for customer satisfaction analysis. Thanks a lot!';

        //==============================================================================================================
        // Invoice
        SalesInvoicePrompt01Lbl: Label 'Need all the items from previous sales invoice';
        SalesInvoicePrompt02Lbl: Label 'Need all the items from sales invoice 12345';
        SalesInvoicePrompt03Lbl: Label 'Need 5 loud speaker from sales invoice';
        SalesInvoicePrompt04Lbl: Label 'Need 5 loud speaker from sales invoice SO12345';
        SalesInvoicePrompt05Lbl: Label 'Need all the items from sales invoice from last week to today';
        SalesInvoicePrompt06Lbl: Label 'Need 5 loud speaker from sales invoice from last week to today';
        SalesInvoicePrompt07Lbl: Label 'Need all the items from sales invoice on 2023-01-01';
        SalesInvoicePrompt08Lbl: Label 'Need all the items from sales invoice on last February 1st';
        // Magic function test: date in future
        SalesInvoicePrompt09Lbl: Label 'Need all the items from sales invoice on next week';
        SalesInvoicePrompt10Lbl: Label 'Need all the items from sales invoice from last month to next week';
        SalesInvoicePrompt11Lbl: Label 'Hi team, please retrieve all electronics from sales invoice 54321 for our tech inventory update. Thanks!';
        SalesInvoicePrompt12Lbl: Label 'Hello, can you list all office supplies from sales invoice 67890? We need it for our office supplies audit.';
        SalesInvoicePrompt13Lbl: Label 'Need a quick favor: gather 10 computer monitors from any sales invoice for our new setup. Thanks!';
        SalesInvoicePrompt14Lbl: Label 'Could you find all good quality items from sales invoice INV98765? It''s for a quality check review.';
        SalesInvoicePrompt15Lbl: Label 'Please select all items under $500 from sales invoice 24680 for our budget analysis. Much appreciated!';
        SalesInvoicePrompt16Lbl: Label 'Hi, can you identify perishable goods from our last sales invoice? It''s urgent for our inventory management.';
        SalesInvoicePrompt17Lbl: Label 'Need details of all discounted items from sales invoice dated 2023-03-15 for our discounts effectiveness review.';
        SalesInvoicePrompt18Lbl: Label 'Can you show items for international shipping from sales invoice 13579? It''s for our global shipping logistics.';
        SalesInvoicePrompt19Lbl: Label 'Please detail all custom orders from sales invoice INV11122 for our custom products analysis.';
        SalesInvoicePrompt20Lbl: Label 'Could you summarize items billed to company X from sales invoice INV22233? It''s for our client billing records.';
        SalesInvoicePrompt21Lbl: Label 'Need to isolate high-value items from sales invoice on last Christmas for our annual high-value sales report.';
        SalesInvoicePrompt22Lbl: Label 'Please review all backordered items from sales invoice INV33344. It''s crucial for our stock replenishment plan.';
        SalesInvoicePrompt23Lbl: Label 'Pinpoint items with express delivery from sales invoice INV44455 for our delivery efficiency analysis.';
        SalesInvoicePrompt24Lbl: Label 'Can you check for any damaged goods in sales invoice 55566? We need to process returns or replacements.';
        SalesInvoicePrompt25Lbl: Label 'Assess all items with warranties from sales invoice 66677 for our warranty services update.';
        SalesInvoicePrompt26Lbl: Label 'Could you find all bulk orders from our recent sales invoices? It''s for our bulk orders management review.';
        SalesInvoicePrompt27Lbl: Label 'Catalog all eco-friendly products from sales invoice 77788 for our sustainability report.';
        SalesInvoicePrompt28Lbl: Label 'Please extract all items from sales invoice 88899 for a comprehensive inventory check.';
        SalesInvoicePrompt29Lbl: Label 'Locate all items with overnight shipping from sales invoice 99900 for our expedited delivery analysis.';
        SalesInvoicePrompt30Lbl: Label 'Retrieve all items purchased by VIP clients from sales invoice 00011 for our VIP client relations enhancement.';
        SalesInvoicePrompt31Lbl: Label 'Subject: Request for additional items \nHello,\nI hope this email finds you well. I am writing to you regarding the sales invoice 123456 that you sent me on January 15, 2024. I appreciate your prompt delivery and excellent service.\nHowever, I would like to request some additional items that are related to the ones I purchased from you. Specifically, I am interested in the following products:\n\t- 10 units of Product A (SKU: 789012)\n\t- 5 units of Product B (SKU: 345678)\n\t- 3 units of Product C (SKU: 901234)\nCould you please send me a quote for these items, along with the shipping and handling fees? I would also appreciate it if you could expedite the order, as I need them by February 10, 2024.\nPlease reply to this email with your confirmation and payment details. If you have any questions or concerns, feel free to contact me at any time.\nThank you for your cooperation and attention.\nSincerely,\nYour customer/colleague';
        //==============================================================================================================
        // Shipment
        SalesShipmentPrompt01Lbl: Label 'Need all the items from previous sales shipment';
        SalesShipmentPrompt02Lbl: Label 'Need all the items from sales shipment SO12345';
        SalesShipmentPrompt03Lbl: Label 'Need 5 loud speaker from sales shipment';
        SalesShipmentPrompt04Lbl: Label 'Need 5 loud speaker from sales shipment SO12345';
        SalesShipmentPrompt05Lbl: Label 'Need all the items from sales shipment from last week to today';
        SalesShipmentPrompt06Lbl: Label 'Need 5 loud speaker from sales shipment from last week to today';
        SalesShipmentPrompt07Lbl: Label 'Need all the items from sales shipment on 2023-01-01';
        SalesShipmentPrompt08Lbl: Label 'Need all the items from sales shipment on last February 1st';
        // Magic function test: date in future
        SalesShipmentPrompt09Lbl: Label 'Need all the items from sales shipment on next week';
        SalesShipmentPrompt10Lbl: Label 'Need all the items from sales shipment from last month to next week';

        SalesShipmentPrompt11Lbl: Label 'Hi team, hope you''re all doing well. Could you kindly list all fragile items from sales shipment 54321? We need to ensure they''re handled with extra care. Thanks a lot!';
        SalesShipmentPrompt12Lbl: Label 'Good morning, I need a quick favor. Can you identify all oversized items from sales shipment 67890? This will help us manage our storage space better. Many thanks!';
        SalesShipmentPrompt13Lbl: Label 'Hello everyone, could someone retrieve 20 office chairs from any of our sales shipments? They are needed urgently for the new conference room setup. Appreciate your help!';
        SalesShipmentPrompt14Lbl: Label 'Hey there, hope your day is going well. Please select items destined for international delivery from shipment SHIP-987651. It''s crucial for our overseas tracking. Thanks!';
        SalesShipmentPrompt15Lbl: Label 'Hi team, can someone find all items in climate-controlled shipping from 2468234320? We need to verify they''re stored correctly for quality assurance. Thanks in advance!';
        SalesShipmentPrompt16Lbl: Label 'Good day, I was wondering if you could detail all rush orders from our recent sales shipments? It''s important for prioritizing our processing queue. Thank you!';
        SalesShipmentPrompt17Lbl: Label 'Hello, can anyone gather all electronic devices from the sales shipment dated 2023-04-10? We need an inventory check for these items. Much appreciated!';
        SalesShipmentPrompt18Lbl: Label 'Hi there, a quick request for you. Could you review all items shipped to California from sales shipment 1354435279? We''re analyzing our regional sales trends. Thanks a bunch!';
        SalesShipmentPrompt19Lbl: Label 'Hey team, please show me all backordered items in shipment SHIP-987651. We need to update our customers on their order statuses. Thanks for your help!';
        SalesShipmentPrompt20Lbl: Label 'Good morning, could someone check for any perishable goods in sales shipment SHIP-987651? We need to ensure they''re shipped promptly to maintain freshness. Thanks!';
        SalesShipmentPrompt21Lbl: Label 'Hi, hope you''re well. Can you isolate items with extended warranties from shipment SHIP-987651? We''re updating our warranty services. Your help is invaluable!';
        SalesShipmentPrompt22Lbl: Label 'Good afternoon, could you catalog all bulk orders from our sales shipment on the 2022 Christmas? It''s for a comprehensive analysis of our holiday sales. Thank you!';
        SalesShipmentPrompt23Lbl: Label 'Hi there, we need a summary of all discounted items from sales shipment 444512315. This will help us review our discount strategies effectively. Can you assist? Thanks!';
        SalesShipmentPrompt24Lbl: Label 'Hello, quick task: please assess items shipped via air freight from shipment SHIP-987651. It''s vital for our logistics efficiency review. Appreciate your efforts!';
        SalesShipmentPrompt25Lbl: Label 'Hey team, can you locate all luxury items from sales shipment 6664312377? We''re tracking our high-end products for a special report. Your swift response would be great!';
        SalesShipmentPrompt26Lbl: Label 'Hi all, could someone pinpoint all items with special handling instructions from shipment 7778123448? It''s crucial to ensure compliance with handling guidelines. Thanks a lot!';
        SalesShipmentPrompt27Lbl: Label 'Good day, I need assistance to extract all items sold to major retailers from shipment 8889911121. It''s part of our retailer sales performance analysis. Your help would be greatly appreciated!';
        SalesShipmentPrompt28Lbl: Label 'Hi, hope you''re having a good day. Please determine all eco-friendly products in sales shipment SHIP-987651 for our sustainability initiatives. Thank you for your attention to this!';
        SalesShipmentPrompt29Lbl: Label 'Hello, a quick request: could you highlight items with delivery delays in shipment SHIP-987651? We need to proactively address any customer concerns. Thanks for your prompt action!';
        SalesShipmentPrompt30Lbl: Label 'Good morning, could you verify all items for express delivery from shipments yesterday? It''s key for assessing our delivery speed. Your quick response is much appreciated!';
        //==============================================================================================================
        // Sales Quote

        SalesQuotePrompt01Lbl: Label 'Need all the items from previous sales Quote';
        SalesQuotePrompt02Lbl: Label 'Need all the items from sales Quote SO12345';
        SalesQuotePrompt03Lbl: Label 'Need 5 loud speaker from sales Quote';
        SalesQuotePrompt04Lbl: Label 'Need 5 loud speaker from sales Quote SO12345';
        SalesQuotePrompt05Lbl: Label 'Need all the items from sales Quote from last week to today';
        SalesQuotePrompt06Lbl: Label 'Need 5 loud speaker from sales Quote from last week to today';
        SalesQuotePrompt07Lbl: Label 'Need all the items from sales Quote on 2023-01-01';
        SalesQuotePrompt08Lbl: Label 'Need all the items from sales Quote on last February 1st';
        // Magic function test: date in future
        SalesQuotePrompt09Lbl: Label 'Need all the items from sales Quote on next week';
        SalesQuotePrompt10Lbl: Label 'Need all the items from sales Quote from last month to next week';
        SalesQuotePrompt11Lbl: Label 'Hi team, hope you''re all doing well. Could you kindly list all fragile items from sales Quote 54321? We need to ensure they''re handled with extra care. Thanks a lot!';
        SalesQuotePrompt12Lbl: Label 'Good morning, I need a quick favor. Can you identify all oversized items from sales Quote 67890? This will help us manage our storage space better. Many thanks!';
        SalesQuotePrompt13Lbl: Label 'Hello everyone, could someone retrieve 20 office chairs from any of our sales Quotes? They are needed urgently for the new conference room setup. Appreciate your help!';
        SalesQuotePrompt14Lbl: Label 'Hey there, hope your day is going well. Please select items destined for international delivery from Quote 987651. It''s crucial for our overseas tracking. Thanks!';
        SalesQuotePrompt15Lbl: Label 'Hi team, can someone find all items in sales quote 2468234320? We need to verify they''re stored correctly for quality assurance. Thanks in advance!';

    [Test]
    procedure TestGetAllFromSalesOrder01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt01Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt02Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt03Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt04Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt05Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesOrder06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt06Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesOrder07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt07Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '2023-01-01', '2023-01-01');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
        LastFeb01: Text;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt08Lbl);
        if (System.Date2DMY(TODAY(), 2) < 3) then
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3) - 1) + '-02-01'
        else
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3)) + '-02-01';
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', LastFeb01, LastFeb01);
    end;

    [Test]
    procedure TestGetAllFromSalesOrder09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt09Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesOrder10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt10Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesOrder11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt11Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '54321', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt12Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '67890', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt13Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '13579', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt14Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', FORMAT(TODAY - 1, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY - 1, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesOrder15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt15Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO24680', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder16()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt16Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO11111', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder17()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt17Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '2023-05-05', '2023-05-05');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder18()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt18Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', Format(System.Date2DMY(TODAY(), 3) - 1) + '-12-25');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder19()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt19Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO22222', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder20()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt20Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO33333', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder21()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt21Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '2023-02-14', '2023-02-14');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder22()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt22Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'ISOD2012345512', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder23()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt23Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO44444', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder24()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt24Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder25()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt25Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO55555', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder26()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt26Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder27()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt27Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder28()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt28Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO66666', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder29()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt29Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', 'SO77777', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesOrder30()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesOrderPrompt30Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_order', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt01Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt02Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt03Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt04Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt05Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt06Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt07Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '2023-01-01', '2023-01-01');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
        LastFeb01: Text;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt08Lbl);
        if (System.Date2DMY(TODAY(), 2) < 3) then
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3) - 1) + '-02-01'
        else
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3)) + '-02-01';
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', LastFeb01, LastFeb01);
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt09Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt10Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt11Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '54321', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt12Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '67890', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt13Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt14Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'INV98765', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt15Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '24680', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice16()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt16Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice17()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt17Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '2023-03-15', '2023-03-15');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice18()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt18Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '13579', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice19()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt19Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'INV11122', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice20()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt20Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'INV22233', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice21()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt21Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', Format(System.Date2DMY(TODAY(), 3) - 1) + '-12-25', Format(System.Date2DMY(TODAY(), 3) - 1) + '-12-25');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice22()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt22Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'INV33344', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice23()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt23Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', 'INV44455', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice24()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt24Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '55566', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice25()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt25Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '66677', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice26()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt26Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice27()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt27Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '77788', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice28()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt28Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '88899', '', '');

    end;

    [Test]
    procedure TestGetAllFromSalesInvoice29()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt29Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '99900', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice30()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt30Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '00011', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesInvoice31()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesInvoicePrompt31Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_invoice', '123456', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt01Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt02Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt03Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt04Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt05Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesShipment06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt06Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesShipment07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt07Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '2023-01-01', '2023-01-01');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
        LastFeb01: Text;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt08Lbl);
        if (System.Date2DMY(TODAY(), 2) < 3) then
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3) - 1) + '-02-01'
        else
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3)) + '-02-01';
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', LastFeb01, LastFeb01);
    end;

    [Test]
    procedure TestGetAllFromSalesShipment09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt09Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesShipment10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt10Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    procedure TestGetAllFromSalesShipment11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt11Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '54321', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt12Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '67890', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt13Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt14Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt15Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '2468234320', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment16()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt16Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment17()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt17Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '2023-04-10', '2023-04-10');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment18()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt18Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '1354435279', '', '');

    end;

    [Test]
    procedure TestGetAllFromSalesShipment19()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt19Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment20()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt20Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    procedure TestGetAllFromSalesShipment21()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt21Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment22()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt22Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', '2022-12-25', '2022-12-25');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment23()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt23Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '444512315', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment24()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt24Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment25()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt25Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '6664312377', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment26()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt26Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '7778123448', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment27()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt27Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '8889911121', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment28()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt28Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment29()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt29Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', 'SHIP-987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesShipment30()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesShipmentPrompt30Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_shipment', '', FORMAT(TODAY - 1, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY - 1, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesQuote01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt01Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt02Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt03Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt04Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', 'SO12345', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt05Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesQuote06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt06Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', FORMAT(TODAY - 7, 0, '<Year4>-<Month,2>-<Day,2>'), FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    [Test]
    procedure TestGetAllFromSalesQuote07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt07Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', '2023-01-01', '2023-01-01');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
        LastFeb01: Text;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt08Lbl);
        if (System.Date2DMY(TODAY(), 2) < 3) then
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3) - 1) + '-02-01'
        else
            LastFeb01 := Format(System.Date2DMY(TODAY(), 3)) + '-02-01';
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', LastFeb01, LastFeb01);
    end;

    [Test]
    procedure TestGetAllFromSalesQuote09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt09Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestGetAllFromSalesQuote10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt10Lbl);
        TestUtil.CheckMagicFunction(CallCompletionAnswerTxt);
    end;

    procedure TestGetAllFromSalesQuote11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt11Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '54321', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt12Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '67890', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt13Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt14Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '987651', '', '');
    end;

    [Test]
    procedure TestGetAllFromSalesQuote15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SalesQuotePrompt15Lbl);
        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document', 'sales_quote', '2468234320', '', '');
    end;

}