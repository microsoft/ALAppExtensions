namespace Microsoft.Sales.Document.Test;

using System.TestLibraries.Utilities;

codeunit 139781 "Search Item Prompt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Search Item] [Prompt]
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        // [START] Common prompts
        CommonPrompt01Lbl: Label 'I need 2 bikes and 4 chairs';
        CommonPrompt02Lbl: Label 'I need 2 kids bikes';
        CommonPrompt03Lbl: Label 'I need the item ''1000''';
        CommonPrompt04Lbl: Label 'I need 2 red lamps and 10 kids bikes';
        // [END] Common prompts

        // [START] Complex prompts
        ComplexPrompt01Lbl: Label 'Looking for a waterproof digital camera for my vacation';
        ComplexPrompt02Lbl: Label 'Interested in organic skincare products for sensitive skin';
        ComplexPrompt03Lbl: Label 'Searching for a beginner-friendly yoga mat and accessories';
        ComplexPrompt04Lbl: Label 'Need a pair of wireless headphones with noise cancellation';
        ComplexPrompt05Lbl: Label 'Seeking a lightweight, portable laptop for business travel';
        ComplexPrompt06Lbl: Label 'Inquire about the latest fantasy novel releases for teenagers';
        ComplexPrompt07Lbl: Label 'Looking for durable hiking boots suitable for mountain trails';
        ComplexPrompt08Lbl: Label 'Need recommendations for high-quality kitchen knife sets';
        ComplexPrompt09Lbl: Label 'Interested in energy-efficient home appliances for a new house';
        ComplexPrompt10Lbl: Label 'Looking for a compact and affordable drone with camera';
        ComplexPrompt11Lbl: Label 'Seeking vintage style decor for a home office setup';
        ComplexPrompt12Lbl: Label 'Inquiring about that plant-based protein powder';
        ComplexPrompt13Lbl: Label 'Interested in home security systems';
        ComplexPrompt14Lbl: Label 'Need a professional-grade DSLR camera for wildlife photography';
        ComplexPrompt15Lbl: Label 'Looking for a comfortable ergonomic chair for long work hours';
        ComplexPrompt16Lbl: Label 'Searching for eco-friendly and reusable kitchenware items';
        ComplexPrompt17Lbl: Label 'Interested in subscription boxes for gourmet food and snacks';
        ComplexPrompt18Lbl: Label 'Inquire about the availability of electric cars for city driving';
        ComplexPrompt19Lbl: Label 'Looking for high-performance running shoes for marathons';
        ComplexPrompt20Lbl: Label 'Seeking information on beginner-friendly home gardening kits';
        ComplexPrompt21Lbl: Label 'Could you help me find the items for children in your store? I need 2 bikes and 4 chairs. Thank you.';
        ComplexPrompt22Lbl: Label 'I am looking for a kids bike. Do you have any in stock?';
        ComplexPrompt23Lbl: Label 'I am interested in the item ''1000''. Can you provide me with more information about it?';
        ComplexPrompt24Lbl: Label 'I need 2 red lamps and 10 toy cars. Can you help me with that?';
        ComplexPrompt25Lbl: Label 'I need the refrigerator model ''ABC123'', height 180 cm, width 60 cm, and depth 65 cm. Do you have it in stock?';
        ComplexPrompt26Lbl: Label 'I need the paper box with height 180 cm, width 60 cm, and depth 65 cm. Do you have it in stock?';
        ComplexPrompt27Lbl: Label 'Could you help me search the item with GTIN ''987651''?';
        ComplexPrompt28Lbl: Label 'I need the TV with GTIN ''987651''. ';
        ComplexPrompt29Lbl: Label 'Help me find the item with GTIN number ''987651''.';
        ComplexPrompt30Lbl: Label 'Could you help me search the item with reference number ''987651''?';
        ComplexPrompt31Lbl: Label 'I need the TV with GTIN ''987651'', larger than 56 inches.';
        ComplexPrompt32Lbl: Label 'Help me find the item with GTIN number ''987651'', larger than 56 inches.';
        ComplexPrompt33Lbl: Label 'I need the TV with brands ''Samsung'' and ''LG''.';
        ComplexPrompt34Lbl: Label 'I need the TV with brands ''Samsung'' and ''LG'' , larger than 56 inches, and 4K resolution. I also need the smart phone with brands ''Samsung'' and ''LG'' .';
        ComplexPrompt35Lbl: Label 'I need all the jacket with brands ''Nike''  and ''Adidas'' , and sizes ''M''  and ''L'' , for kids and adults.';
        ComplexPrompt36Lbl: Label 'Inquire about the information of electric cars for city driving with brands ''Tesla''  and ''Nissan''  and price range between $30,000 and $50,000.';
        ComplexPrompt37Lbl: Label 'Could you check the number of books with the title ''The Art of Happiness'' by Dalai Lama and Howard Cutler?';
        ComplexPrompt38Lbl: Label 'I need the pencil with the brand ''Faber-Castell''  and the color ''black''  and ''blue''. And it should be erased easily.';
        ComplexPrompt39Lbl: Label 'Help me find the white door with height 180 cm, width 60 cm, and the price range is between $100 and $200.';
        ComplexPrompt40Lbl: Label 'I need the snacks with the brand ''Lay''s'' and ''Pringles'', and the price is $1, and the flavor is ''sour cream''.';
        ComplexPrompt41Lbl: Label 'Inquire the information of the smartwatch with the brand ''Samsung'' and ''Apple'', and the price range is between $200 and $300.';
        // [END] Complex prompts

        // [START] Email prompts
        EmailPrompt01Lbl: Label 'Hello,I am writing to express my satisfaction with the laptop I purchased from your online store last month. It is a Dell Inspiron 15 3000 Series Laptop, and I am very happy with its performance, design, and features. It is exactly what I was looking for, and I appreciate your excellent customer service and fast delivery.I am interested in buying some accessory for my laptop, such as a wireless mouse, a keyboard cover, and a laptop bag. I wonder if you have any recommendations or suggestions for these items. Do you have any special offers or discounts for loyal customers like me?Please let me know if you can help me with this inquiry. I look forward to hearing from you soon.Thank you for your attention and service.Sincerely, John Smith';
        EmailPrompt02Lbl: Label 'Greetings, I just wanted to say that I really enjoyed reading a book that I ordered from your online store. The book is called “The Art of Happiness” by Dalai Lama and Howard Cutler. It is a wonderful book that teaches how to live a happier and more meaningful life. I learned a lot from the book and I feel more positive and peaceful. I think everyone should read this book and apply its teachings to their own lives. I also want to buy another book from your online store, but something totally different. I am interested in learning more about planting. Do you have any books that can introduce me to this topic? I would appreciate your suggestions. Thank you for your great service and I look forward to hearing from you soon. Best regards, John Smith';
        EmailPrompt03Lbl: Label 'Hello,I am a regular visitor of your website and I have been impressed by the variety and quality of the products you offer. I am particularly interested in buying a smartwatch that can track my fitness, health, and notifications. I have seen the Samsung Galaxy Watch Active 2 on your website and I think it is the perfect match for me. It has a sleek design, a touch bezel, a heart rate monitor, an ECG sensor, and a long battery life. It is also compatible with both Android and iOS devices, which is very convenient for me. I need all the information of this item Samsung Galaxy Watch Active 2. I would like to know more about the features, specifications, and warranty of this smartwatch. How does it compare to other models in the market? What are the payment and delivery options? Do you have any customer reviews or testimonials for this product? Please reply to this email with the information I requested. I am eager to buy this smartwatch from you as soon as possible. Thank you for your time and attention. Sincerely, Jane Doe';
        EmailPrompt04Lbl: Label 'Hello,I am writing to inquire about a leather jacket that I saw on your online store. It is a black leather jacket with a zipper closure, a stand collar, and four pockets. It is made of genuine leather and has a soft lining. It is available in different sizes and colors. I am very interested in buying this leather jacket because it looks stylish, comfortable, and durable. I think it would suit my personality and wardrobe. I have a few questions before I make the purchase: * How can I measure myself to find the right size for me? * How can I take care of the leather jacket to maintain its quality and appearance? * How long will it take for the leather jacket to be delivered to my address? * What is your return and exchange policy in case I am not satisfied with the product? \\ Please answer these questions and provide me with any other information that you think might be helpful. I appreciate your prompt and courteous response. Thank you for your service and cooperation.Sincerely, John Smith';
        EmailPrompt05Lbl: Label 'Hello Stan, I liked your pitch and the quality of your bikes seem to meet and exceed our standards, can you ship over a couple of samples, e.g. some kid''s bikes and maybe a model for women as well as a mountainbike. I''ll return them if we can''t agree but in case we sign the deal, I''ll pay for them. Is that okay with you? Best regards Mike Bikes-R-Us';
        EmailPrompt06Lbl: Label 'Hello, I''m Bob, a gardening enthusiast. I''m very interested in your organic fertilizer range. Could you tell me more about the ingredients and benefits? I want all the information of this item. Also, I recently moved to a new city and am excited to start my garden here. Thanks, Bob';
        EmailPrompt07Lbl: Label 'Dear Team, Bob here. I''ve been a professional photographer for years and I''ve just returned from a wildlife photography trip in Africa. I''m interested in your new range of mirrorless cameras. Can you provide some insights on their performance in low light? I would like the related information of this item. Regards, Bob';
        EmailPrompt08Lbl: Label 'Hi, I''m Bob, an aspiring chef. I came across your culinary school''s advanced courses and I''m curious about the rice cooker you recommend in the lecture. It is large. By the way, I recently won a local cooking competition with my signature dish. Cheers, Bob';
        EmailPrompt09Lbl: Label 'Greetings, Bob here. I''m looking for a new mountain bike and I''m intrigued by the models on your website. Could you show me more information of the bike? I''m also a volunteer trail maintenance worker on weekends. Thanks, Bob';
        EmailPrompt10Lbl: Label 'Hello, this is Bob, a music teacher. I''m interested in your collection of vintage guitars. Could you send me a list of available models and their conditions? I plan to purchase some. Also, I''ve been teaching music to underprivileged children for the past year. Best, Bob';
        EmailPrompt11Lbl: Label 'Hey, Bob here. I''m a tech enthusiast and I''m curious about your latest range of gaming laptops. Can you provide details on their graphics and processing capabilities? I guess I need one.  Additionally, I recently organized a local eSports tournament. Thanks, Bob';
        EmailPrompt12Lbl: Label 'Hi there, I''m Bob, an amateur astronomer. I''m fascinated by your telescopes and would like more information on their magnification and stability. Also, I''m planning to host a stargazing event for my community soon. Regards, Bob';
        EmailPrompt13Lbl: Label 'Hello, Bob here, a freelance writer. I''m in the market for a new ergonomic office chair. Could you suggest some models that are good for long hours of writing? By the way, I just finished writing my first novel. Thanks, Bob';
        EmailPrompt14Lbl: Label 'Dear Sir or Madam, I''m Bob, an interior designer. I''m interested in your range of sustainable home decor. Can you share more about it? I need to get one. Also, I''ve recently been involved in designing eco-friendly office spaces. Sincerely, Bob';
        EmailPrompt15Lbl: Label 'Hello, my name is Bob, a fitness coach. I''m looking for high-quality yoga mats for my classes. Can you provide information on their durability and grip? Additionally, I recently started a free fitness boot camp in the park. Cheers, Bob';
        // Email: Reference to sales invoice but actually just need additional items
        EmailPrompt16Lbl: Label 'Subject: Request for additional items \nHello,\nI hope this email finds you well. I am writing to you regarding the sales invoice 123456 that you sent me on January 15, 2024. I appreciate your prompt delivery and excellent service.\nHowever, I would like to request some additional items that are related to the ones I purchased from you. Specifically, I am interested in the following products:\n\t- 10 units of Product A (SKU: 789012)\n\t- 5 units of Product B (SKU: 345678)\n\t- 3 units of Product C (SKU: 901234)\nCould you please send me a quote for these items, along with the shipping and handling fees? I would also appreciate it if you could expedite the order, as I need them by February 10, 2024.\nPlease reply to this email with your confirmation and payment details. If you have any questions or concerns, feel free to contact me at any time.\nThank you for your cooperation and attention.\nSincerely,\nYour customer/colleague';
        // Email: Missing items from sales shipment
        EmailPrompt17Lbl: Label 'Subject: Urgent: Missing Items in Recent Sales Shipment\n\nDear [Your Name],\n\nI hope this email finds you well. I am writing to bring to your attention an issue with our latest sales shipment for our client, Stellar Tech Innovations.\n\nUpon reviewing the shipment, it appears that several items from our "Galaxy" product line are missing. The missing items include:\n\n1. **10 units** of our **Orion Keyboards**\n2. **15 units** of **Andromeda Mice**\n3. **5 units** of **Pegasus High-Speed HDMI Cables**\n\nThese items were included in the sales order (SO4567) dated January 15, 2024, but were not found in the shipment received by Stellar Tech Innovations.\n\nCould you please look into this matter urgently and advise on the next steps? We need to ensure these items are sent to Stellar Tech Innovations as soon as possible to maintain our service level agreement.\n\nThank you for your prompt attention to this matter.\n\nBest Regards,\n\n[Colleague''s Name]\nSales Department\nInterstellar Computing Inc.';
        // Email: Missing items from order with some maths to do (failing as of January 23rd)
        EmailPrompt18Lbl: Label 'Subject: Request for Missing Items\n\nDear [Your Name],\n\nI hope this email finds you well. I am writing to inform you that I received my recent order from your company, but unfortunately, some items are missing from the shipment. I was expecting to receive the following items:\n\n- **2 boxes of 12-pack Coca-Cola cans**\n- **1 box of 24-pack Pepsi cans**\n- **1 box of 6-pack KitKat bars**\n\nHowever, I only received the following items:\n\n- **1 box of 12-pack Coca-Cola cans**\n- **1 box of 24-pack Pepsi cans**\n\nI would appreciate it if you could look into this matter and send me the missing items as soon as possible. Please let me know if you need any further information from me.\n\nThank you for your attention to this matter.\n\nBest regards,\n\nJohn Smith\n';
        // Email: Additional items
        EmailPrompt19Lbl: Label 'Subject: Request for additional items from Zephyr Inc.\n\nHello John,\n\nI hope this email finds you well. I am writing to you on behalf of Zephyr Inc., one of your valued customers.\n\nWe are very pleased with the quality and performance of the products we received from your company, Solaris Solutions, in our last order. We appreciate your timely delivery and excellent customer service.\n\nHowever, we have realized that we need some additional items to complete our project. Specifically, we would like to request the following:\n\n- 10 units of Solaris Smart Thermostat (Model ST-2024)\n- 5 units of Solaris Solar Panel (Model SP-2024)\n- 2 units of Solaris Battery Pack (Model BP-2024)\n\nWe would appreciate it if you could confirm the availability and price of these items as soon as possible. We would also like to know the estimated delivery time and shipping cost.\n\nPlease reply to this email or call me at +44 20 1234 5678 if you have any questions or concerns. We look forward to hearing from you and continuing our business relationship with Solaris Solutions.\n\nThank you for your attention and cooperation.\n\nSincerely,\nEmma Smith\nSales Manager\nZephyr Inc.\n';
        // Email: asking to create a new sales order for "next Monday".
        EmailPrompt20Lbl: Label 'Subject: Sales invoice reminder\n\nHi John,\n\nI hope this email finds you well and that you are enjoying your work as a sales representative at ABC Inc.\n\nI am writing to remind you that you need to create a sales invoice for the order you received from XYZ Ltd. last week. The invoice should be ready by next Monday, January 29, 2024, and sent to the customer via email.\n\nPlease make sure to include the following items in the invoice:\n\n- Product name: Widget 3000\n- Quantity: 50 units\n- Unit price: £100\n- Total price: £5,000\n- VAT: 20%\n- Grand total: £6,000\n- Payment terms: 30 days from invoice date\n- Bank details: ABC Inc., Sort code: 12-34-56, Account number: 12345678\n\nIf you have any questions or need any assistance, please do not hesitate to contact me.\n\nThank you for your hard work and dedication.\n\nSincerely,\n\nJane Smith\nSales Manager\nABC Inc.\n';
        // [END] Email prompts  

        // [START] Spelling errors 
        SpellingErrorPrompt02Lbl: Label 'I want 2 bkies and 4 charis';
        // [END] Spelling errors

        // [START] Multiple Language
        MultiLanguagePrompt01Lbl: Label 'I need one bike with brand ''凤凰''';
    // [END] Multiple Language

    [Test]
    procedure TestSearchPrompt01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, CommonPrompt01Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');

        LibraryVariableStorage.Enqueue('chair');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('4');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, CommonPrompt02Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');
        LibraryVariableStorage.Enqueue('kids');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, CommonPrompt03Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('1000');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, CommonPrompt04Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('lamp');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');
        LibraryVariableStorage.Enqueue('red');

        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('10');
        LibraryVariableStorage.Enqueue('kids');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, SpellingErrorPrompt02Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('bkies');
        LibraryVariableStorage.Enqueue('2');

        LibraryVariableStorage.Enqueue('chair');
        LibraryVariableStorage.Enqueue('charis');
        LibraryVariableStorage.Enqueue('4');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt01Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('wireless mouse');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');

        LibraryVariableStorage.Enqueue('keyboard cover');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');

        LibraryVariableStorage.Enqueue('laptop bag');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 3, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt02Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('book');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('planting');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt03Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('smartwatch');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        // features
        LibraryVariableStorage.Enqueue('Samsung Galaxy Watch Active 2|smartwatch|fitness tracking|health tracking|notifications|sleek design|touch bezel|heart rate monitor|ECG sensor|long battery life|Android compatibility|iOS compatibility');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt04Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('leather jacket');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('black|zipper closure|stand collar|four pockets|genuine leather|soft lining|different sizes|different colors');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt05Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('kid''s');

        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Women''s');

        LibraryVariableStorage.Enqueue('mountain bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 3, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt01Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('digital camera');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('waterproof');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt02Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('skincare product');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('organic|for sensitive skin');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt03Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('yoga mat');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('beginner-friendly|yoga');

        LibraryVariableStorage.Enqueue('yoga accessory');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('beginner-friendly|yoga');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt04Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('headphone');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('wireless|noise cancellation');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt05Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('laptop');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('lightweight|portable|for business travel|fantasy');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt16()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt06Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('novel');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('fantasy|latest|teenagers');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt17()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt07Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('hiking boot');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('durable|suitable for mountain trails');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt18()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt08Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('kitchen knife set');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('high-quality');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt19()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt09Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('home appliance');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('energy-efficient|new house');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt20()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt10Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('drone');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('compact|affordable|with camera');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt21()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt11Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('decor');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('vintage style|home office setup');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt22()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt12Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('protein powder');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('plant-based');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt23()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt13Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('home security system');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt24()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt14Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('dslr camera');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('professional-grade|for wildlife photography');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt25()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt15Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('chair');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('comfortable|ergonomic|for long work hours');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt26()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt16Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('kitchenware');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('eco-friendly|reusable');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt27()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt17Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('subscription box');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('gourmet food|snacks');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt28()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt18Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('electric car');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('city driving');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;


    [Test]
    procedure TestSearchPrompt29()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt20Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('home gardening kit');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('beginner-friendly');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt30()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt19Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('running shoe');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('high-performance|for marathons');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt31()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt06Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('organic fertilizer');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt32()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt07Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('mirrorless camera');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('new range|low light performance');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt33()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt08Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('rice cooker');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('large');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt34()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt09Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('new | mountain ');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt35()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt10Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('guitar');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('0');
        LibraryVariableStorage.Enqueue('vintage');

        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt36()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt11Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('gaming laptop');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('graphics|processing capabilities');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt37()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt12Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('telescope');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('magnification|stability');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt38()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt13Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('office chair');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('ergonomic');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt39()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt14Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('home decor');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('sustainable');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt40()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt15Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('yoga mat');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('high quality|durability|grip');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt41()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt16Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('product a');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('10');
        LibraryVariableStorage.Enqueue('SKU: 789012');
        LibraryVariableStorage.Enqueue('product b');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue('SKU: 345678');
        LibraryVariableStorage.Enqueue('product c');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('3');
        LibraryVariableStorage.Enqueue('SKU: 901234');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 3, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt42()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt17Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Keyboard');
        LibraryVariableStorage.Enqueue('Orion Keyboards');
        LibraryVariableStorage.Enqueue('10');
        LibraryVariableStorage.Enqueue('Orion');
        LibraryVariableStorage.Enqueue('Mouse');
        LibraryVariableStorage.Enqueue('Andromeda Mice');
        LibraryVariableStorage.Enqueue('15');
        LibraryVariableStorage.Enqueue('Andromeda');
        LibraryVariableStorage.Enqueue('HDMI Cable');
        LibraryVariableStorage.Enqueue('Pegasus High-Speed HDMI Cables');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue('Pegasus|High-Speed');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 3, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt43()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt18Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Coca-Cola can');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('12-pack|box');
        LibraryVariableStorage.Enqueue('KitKat bar');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('6-pack|box');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt44()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt19Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Smart Thermostat');
        LibraryVariableStorage.Enqueue('solaris smart thermostat');
        LibraryVariableStorage.Enqueue('10');
        LibraryVariableStorage.Enqueue('Solaris|Model ST-2024');
        LibraryVariableStorage.Enqueue('Solar Panel');
        LibraryVariableStorage.Enqueue('solaris solar panel');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue('Solaris|Model SP-2024');
        LibraryVariableStorage.Enqueue('Battery Pack');
        LibraryVariableStorage.Enqueue('Solaris Battery Pack');
        LibraryVariableStorage.Enqueue('2');
        LibraryVariableStorage.Enqueue('Solaris|Model BP-2024');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 3, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt45()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, EmailPrompt20Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Widget');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('50');
        LibraryVariableStorage.Enqueue('3000');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt46()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt21Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');
        LibraryVariableStorage.Enqueue('children');
        LibraryVariableStorage.Enqueue('chair');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('4');
        LibraryVariableStorage.Enqueue('children');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt47()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt22Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('kids');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt48()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt23Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('1000');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt49()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt24Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('lamp');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');
        LibraryVariableStorage.Enqueue('red');
        LibraryVariableStorage.Enqueue('toy car');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('10');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt50()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt25Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('refrigerator');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('model ABC123|height 180 cm|width 60 cm|depth 65 cm');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt51()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt26Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('paper box');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('height 180 cm|width 60 cm|depth 65 cm');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt52()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt27Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt53()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt28Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('TV');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt54()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt29Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt55()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt30Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt56()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt31Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('TV');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''|larger than 56 inches');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt57()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt32Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('item');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('GTIN 987651|GTIN ''987651''|larger than 56 inches');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt58()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt33Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('TV');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Samsung|LG');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt59()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt34Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('TV');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Samsung|LG|larger than 56 inches|4K resolution');
        LibraryVariableStorage.Enqueue('smart phone');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Samsung|LG');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 2, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt60()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt35Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('jacket');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('0');
        LibraryVariableStorage.Enqueue('Nike|Adidas|M|L|kids|adults');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt61()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt36Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('electric car');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('city driving|Tesla|Nissan|$30,000 - $50,000');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt62()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt37Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Book');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('The Art of Happiness|Dalai Lama|Howard Cutler');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt63()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt38Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('pencil');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Faber-Castell|black|blue|erasable');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt64()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt39Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('door');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('white|height 180 cm|width 60 cm|price range $100-$200');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt65()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt40Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('snack');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Lay''s|Pringles|sour cream|$1');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt66()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ComplexPrompt41Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('smartwatch');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('Samsung|Apple|price between $200 and $300');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;

    [Test]
    procedure TestSearchPrompt67()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, MultiLanguagePrompt01Lbl);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Bike');
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue('凤凰');
        TestUtil.CheckSearchItemJSONContent(CallCompletionAnswerTxt, 1, LibraryVariableStorage);
    end;
}