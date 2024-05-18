namespace Microsoft.Sales.Document.Test;

codeunit 139786 "Item Search In Doc Prompt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Document Lookup] [Item Search] [Prompt] 
    end;

    var
        // Item Search in Document Prompt
        ItemSearchInDocPrompt01Lbl: Label 'Add 4 whiteboards from invoice 123456';
        ItemSearchInDocPrompt02Lbl: Label 'Add whiteboards from last invoice';
        ItemSearchInDocPrompt03Lbl: Label 'Add whiteboards from last invoice for customer 10000';
        ItemSearchInDocPrompt04Lbl: Label 'Copy all lines from quote 123456';
        ItemSearchInDocPrompt05Lbl: Label 'I need a bike from invoice "1234"';
        ItemSearchInDocPrompt06Lbl: Label 'I need 5 bikes from invoice "1234"';
        ItemSearchInDocPrompt07Lbl: Label 'I need 5 different bikes from invoice "1234"';
        ItemSearchInDocPrompt08Lbl: Label 'I need all bikes from invoice "1234"';
        ItemSearchInDocPrompt09Lbl: Label 'I need bikes and wheels from invoice "1234".';
        ItemSearchInDocPrompt10Lbl: Label 'I need the following from the invoice "1234": all bikes, 4 front wheels, and brakes.';
        ItemSearchInDocPrompt11Lbl: Label 'I need bikes from the last invoice.';
        ItemSearchInDocPrompt12Lbl: Label 'I need bikes from invoice posted last year.';
        ItemSearchInDocPrompt13Lbl: Label 'I need only blue bikes from invoice "1234".';
        ItemSearchInDocPrompt14Lbl: Label 'I need blue and red bikes from invoice "1234".';
        ItemSearchInDocPrompt15Lbl: Label 'I need items starting with A* from the invoice "1234".';


    [Test]
    procedure TestItemSearchInDocument01()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] Add 4 whiteboards from invoice 123456
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt01Lbl);

        TestUtil.AddDocument('sales_invoice', '123456', '', '');
        TestUtil.AddItem('whiteboard', '', '4', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument02()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] Add whiteboards from last invoice
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt02Lbl);

        TestUtil.AddDocument('sales_invoice', '', '', '');
        TestUtil.AddItem('whiteboard', '', '1', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument03()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] Add whiteboards from last invoice for customer 10000
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt03Lbl);

        TestUtil.AddDocument('sales_invoice', '', '', '');
        TestUtil.AddItem('whiteboard', '', '1', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument04()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] Copy all lines from quote 123456
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt04Lbl);

        TestUtil.AddDocument('sales_quote', '123456', '', '');

        TestUtil.CheckDocumentLookupJSONContent(CallCompletionAnswerTxt, 'lookup_from_document');
    end;

    [Test]
    procedure TestItemSearchInDocument05()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need a bike from invoice "1234"
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt05Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '1', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument06()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need 5 bikes from invoice "1234"
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt06Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '5', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument07()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need 5 different bikes from invoice "1234"
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt07Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '5', 'different');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument08()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need all bikes from invoice "1234"
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt08Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '0', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument09()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need bikes and wheels from invoice "1234".
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt09Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '1', '');
        TestUtil.AddItem('wheel', '', '1', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument10()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need the following from the invoice "1234": all bikes, 4 front wheels, and brakes.
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt10Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');

        TestUtil.AddItem('bike', '', '0', '');

        TestUtil.AddItem('front wheel', '', '4', '');

        TestUtil.AddItem('brake', '', '0', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument11()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need bikes from the last invoice.
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt11Lbl);

        TestUtil.AddDocument('sales_invoice', '', '', '');
        TestUtil.AddItem('bike', '', '0', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument12()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
        EndDate: Date;
    begin
        // [PROMPT] I need bikes from invoice posted last year.
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt12Lbl);

        EndDate := CalcDate('<-1Y>', Today());
        TestUtil.AddDocument('sales_invoice', '', '', Format(EndDate, 0, '<year4>-<month,2>-<day,2>'));
        TestUtil.AddItem('bike', '', '0', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument13()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need only blue bikes from invoice "1234".
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt13Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '0', 'blue');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument14()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need blue and red bikes from invoice "1234".
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt14Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('bike', '', '0', 'blue,red');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;

    [Test]
    procedure TestItemSearchInDocument15()
    var
        TestUtil: Codeunit "SLS Test Utility";
        CallCompletionAnswerTxt: SecretText;
    begin
        // [PROMPT] I need items starting with A* from the invoice "1234".
        TestUtil.RepeatAtMost100TimesToFetchCompletion(CallCompletionAnswerTxt, ItemSearchInDocPrompt15Lbl);

        TestUtil.AddDocument('sales_invoice', '1234', '', '');
        TestUtil.AddItem('A*', '', '0', '');

        TestUtil.CheckItemSearchInDocJSONContent(CallCompletionAnswerTxt);
    end;
}