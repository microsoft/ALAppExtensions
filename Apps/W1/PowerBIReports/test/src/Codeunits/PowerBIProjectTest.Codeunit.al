#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Projects.Project.Job;
using System.Text;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Projects.PowerBIReports;

codeunit 139879 "PowerBI Project Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibPurch: Codeunit "Library - Purchase";
        LibJob: Codeunit "Library - Job";
        LibInv: Codeunit "Library - Inventory";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestGetJobs()
    var
        Job: Record Job;
        Job2: Record Job;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Jobs are created
        LibJob.CreateJob(Job);
        Job.Validate("Starting Date", WorkDate());
        Job.Validate("Ending Date", WorkDate() + 10);
        Job.Modify(true);
        LibJob.CreateJob(Job2);
        Job2.Validate("Starting Date", Today());
        Job2.Validate("Ending Date", Today() + 10);
        Job2.Modify(true);
        Job.SetFilter("No.", '%1|%2', Job."No.", Job2."No.");
        Commit();

        // [WHEN] Get request for jobs is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Jobs, '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('no eq ''%1'' or no eq ''%2''', Job."No.", Job2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the job information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if Job.FindSet() then
            repeat
                VerifyJob(Response, Job);
            until Job.Next() = 0;
    end;

    local procedure VerifyJob(Response: Text; Job: Record Job)
    var
        JsonMgt: Codeunit "JSON Management";
        BoolText: Text;
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', Job."No.")), 'Job not found.');
        Assert.AreEqual(Job.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Job."Bill-to Customer No.", JsonMgt.GetValue('billToCustomerNo'), 'Bill-to customer no. did not match.');
        Assert.AreEqual(Format(Job."Creation Date", 0, 9), JsonMgt.GetValue('creationDate'), 'Creation date did not match.');
        Assert.AreEqual(Format(Job."Starting Date", 0, 9), JsonMgt.GetValue('startingDate'), 'Starting date did not match.');
        Assert.AreEqual(Format(Job."Ending Date", 0, 9), JsonMgt.GetValue('endingDate'), 'Ending date did not match.');
        Assert.AreEqual(Format(Job.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(Job."Job Posting Group", JsonMgt.GetValue('jobPostingGroup'), 'Job posting group did not match.');
        Assert.AreEqual(Format(Job.Blocked), JsonMgt.GetValue('blocked'), 'Blocked did not match.');
        Assert.AreEqual(Job."Project Manager", JsonMgt.GetValue('projectManager'), 'Project manager did not match.');
        BoolText := 'False';
        if Job.Complete then
            BoolText := 'True';
        Assert.AreEqual(BoolText, JsonMgt.GetValue('complete'), 'Complete did not match.');
    end;

    [Test]
    procedure TestGetJobTasks()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobTask2: Record "Job Task";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Job tasks are created
        LibJob.CreateJob(Job);
        LibJob.CreateJobTask(Job, JobTask);
        LibJob.CreateJobTask(Job, JobTask2);
        JobTask.SetRange("Job No.", Job."No.");
        Commit();

        // [WHEN] Get request for job tasks is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Job Tasks", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('jobNo eq ''%1''', Job."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the job task information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if JobTask.FindSet() then
            repeat
                VerifyJobTask(Response, JobTask);
            until JobTask.Next() = 0;
    end;

    local procedure VerifyJobTask(Response: Text; JobTask: Record "Job Task")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.jobTaskNo == ''%1'')]', JobTask."Job Task No.")), 'Job task not found.');
        Assert.AreEqual(JobTask.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(JobTask.Totaling, JsonMgt.GetValue('totaling'), 'Totaling did not match.');
        Assert.AreEqual(Format(JobTask."Job Task Type"), JsonMgt.GetValue('jobTaskType'), 'Job task type did not match.');
        Assert.AreEqual(Format(JobTask.Indentation), JsonMgt.GetValue('indentation'), 'Indentation did not match.');
    end;

    [Test]
    procedure TestGetJobPlanningLines()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Job planning lines are created
        LibJob.CreateJob(Job);
        LibJob.CreateJobTask(Job, JobTask);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Resource, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", LibJob.CreateConsumable(JobPlanningLine.Type::Resource));
        JobPlanningLine.Modify(true);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Resource, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", LibJob.CreateConsumable(JobPlanningLine.Type::Resource));
        JobPlanningLine.Modify(true);
        JobPlanningLine.SetRange("Job No.", Job."No.");

        Commit();

        // [WHEN] Get request for job planning lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Job Planning Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('jobNo eq ''%1''', Job."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the job planning line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if JobPlanningLine.FindSet() then
            repeat
                VerifyJobPlanningLine(Response, JobPlanningLine);
            until JobPlanningLine.Next() = 0;
    end;

    local procedure VerifyJobPlanningLine(Response: Text; JobPlanningLine: Record "Job Planning Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', JobPlanningLine."No.")), 'Job planning line not found.');
        Assert.AreEqual(JobPlanningLine."Job No.", JsonMgt.GetValue('jobNo'), 'Job no. did not match.');
        Assert.AreEqual(JobPlanningLine."Job Task No.", JsonMgt.GetValue('jobTaskNo'), 'Job task no. did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Line No."), JsonMgt.GetValue('lineNo'), 'Line no. did not match.');
        Assert.AreEqual(Format(JobPlanningLine.Type), JsonMgt.GetValue('jobType'), 'Job type did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Line Type"), JsonMgt.GetValue('lineType'), 'Line type did not match.');
        Assert.AreEqual(JobPlanningLine."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(JobPlanningLine.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Format(JobPlanningLine.Quantity, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Unit cost (LCY) did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Total Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('totalCostLCY'), 'Total cost (LCY) did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Unit Price (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitPriceLCY'), 'Unit price (LCY) did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Line Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('lineAmountLCY'), 'Line amount (LCY) did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Total Price (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('totalPriceLCY'), 'Total price (LCY) did not match.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestGetJobLedgerEntries()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        JobJournalLine: Record "Job Journal Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Job ledger entries are posted
        LibJob.CreateJob(Job);
        LibJob.CreateJobTask(Job, JobTask);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Resource, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", LibJob.CreateConsumable(JobPlanningLine.Type::Resource));
        JobPlanningLine.Validate(Quantity, LibRandom.RandDecInRange(10, 100, 2));
        JobPlanningLine.Validate("Unit Price", LibRandom.RandDecInRange(10, 100, 2));
        JobPlanningLine.Modify(true);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Resource, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", LibJob.CreateConsumable(JobPlanningLine.Type::Resource));
        JobPlanningLine.Validate(Quantity, LibRandom.RandDecInRange(10, 100, 2));
        JobPlanningLine.Validate("Unit Price", LibRandom.RandDecInRange(10, 100, 2));
        JobPlanningLine.Modify(true);
        JobLedgerEntry.SetRange("Job No.", Job."No.");

        LibJob.UseJobPlanningLine(JobPlanningLine, Enum::"Job Line Type"::"Both Budget and Billable", 1, JobJournalLine);
        Commit();

        // [WHEN] Get request for job ledger entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Microsoft.Projects.PowerBIReports."Job Ledger Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('jobNo eq ''%1''', Job."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the job ledger entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if JobLedgerEntry.FindSet() then
            repeat
                VerifyJobLedgerEntry(Response, JobLedgerEntry);
            until JobLedgerEntry.Next() = 0;
    end;

    local procedure VerifyJobLedgerEntry(Response: Text; JobLedgerEntry: Record "Job Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', JobLedgerEntry."No.")), 'Job ledger entry not found.');
        Assert.AreEqual(JobLedgerEntry."Job No.", JsonMgt.GetValue('jobNo'), 'Job no. did not match.');
        Assert.AreEqual(JobLedgerEntry."Job Task No.", JsonMgt.GetValue('jobTaskNo'), 'Job task no. did not match.');
        Assert.AreEqual(Format(JobLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(JobLedgerEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Entry type did not match.');
        Assert.AreEqual(Format(JobLedgerEntry.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(JobLedgerEntry."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(JobLedgerEntry.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(JobLedgerEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(JobLedgerEntry."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
        Assert.AreNearlyEqual(JobLedgerEntry.Quantity, CastToDecimal(JsonMgt.GetValue('quantity')), 0.01, 'Quantity did not match.');
        Assert.AreNearlyEqual(JobLedgerEntry."Unit Cost (LCY)", CastToDecimal(JsonMgt.GetValue('unitCostLCY')), 0.01, 'Unit cost (LCY) did not match.');
        Assert.AreNearlyEqual(JobLedgerEntry."Total Cost (LCY)", CastToDecimal(JsonMgt.GetValue('totalCostLCY')), 0.01, 'Total cost (LCY) did not match.');
        Assert.AreNearlyEqual(JobLedgerEntry."Unit Price", CastToDecimal(JsonMgt.GetValue('unitPrice')), 0.01, 'Unit price did not match.');
        Assert.AreNearlyEqual(JobLedgerEntry."Total Price (LCY)", CastToDecimal(JsonMgt.GetValue('totalPriceLCY')), 0.01, 'Total price (LCY) did not match.');
        Assert.AreEqual(Format(JobLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestGetOutstandingPOLines()
    var
        Job: Record Job;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase order is created with outstanding lines
        LibJob.CreateJob(Job);
        CreatePOWithJob(PurchHeader, Job);
        PurchLine.SetRange("Job No.", Job."No.");
        Commit();

        // [WHEN] Get request for outstanding PO lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Job Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('jobNo eq ''%1''', Job."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the outstanding PO line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if PurchLine.FindSet() then
            repeat
                VerifyOutstandingPOLine(Response, PurchLine);
            until PurchLine.Next() = 0;
    end;

    local procedure VerifyOutstandingPOLine(Response: Text; PurchaseLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', PurchaseLine."No.")), 'Outstanding PO line not found.');
        Assert.AreEqual(Format(PurchaseLine."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
        Assert.AreEqual(PurchaseLine."Document No.", JsonMgt.GetValue('documentNo'), 'Document no. did not match.');
        Assert.AreEqual(PurchaseLine."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(Format(PurchaseLine.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(PurchaseLine."Outstanding Qty. (Base)", 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Outstanding quantity (base) did not match.');
        Assert.AreEqual(Format(PurchaseLine."Outstanding Amount (LCY)", 0, 9), JsonMgt.GetValue('outstandingAmountLCY'), 'Outstanding amount (LCY) did not match.');
        Assert.AreEqual(PurchaseLine."Job No.", JsonMgt.GetValue('jobNo'), 'Job no. did not match.');
        Assert.AreEqual(PurchaseLine."Job Task No.", JsonMgt.GetValue('jobTaskNo'), 'Job task no. did not match.');
        Assert.AreEqual(Format(PurchaseLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Expected receipt date did not match.');
        Assert.AreEqual(Format(PurchaseLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(PurchaseLine.Description, JsonMgt.GetValue('description'), 'Description did not match.');
    end;

    [Test]
    procedure TestGetOutstandingPurchOrderLineOutsideFilter()
    var
        PurchHeader: Record "Purchase Header";
        PurchHeader2: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase lines exist outside of the query filter
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := LibUtility.GenerateRandomCode20(PurchHeader.FieldNo("No."), Database::"Purchase Header");
        PurchHeader.Insert();
        PurchLine.Init();
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine."No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("No."), Database::"Purchase Line");
        PurchLine."Job No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Job No."), Database::"Purchase Line");
        PurchLine."Job Task No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Job Task No."), Database::"Purchase Line");
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine.Insert();

        PurchHeader2.Init();
        PurchHeader2."Document Type" := PurchHeader2."Document Type"::Quote;
        PurchHeader2."No." := LibUtility.GenerateRandomCode20(PurchHeader2.FieldNo("No."), Database::"Purchase Header");
        PurchHeader2.Insert();
        PurchLine.Init();
        PurchLine."Document Type" := PurchHeader2."Document Type";
        PurchLine."Document No." := PurchHeader2."No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine."No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("No."), Database::"Purchase Line");
        PurchLine."Job No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Job No."), Database::"Purchase Line");
        PurchLine."Job Task No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Job Task No."), Database::"Purchase Line");
        PurchLine."Outstanding Qty. (Base)" := 1;
        PurchLine.Insert();

        Commit();

        // [WHEN] Get request for the purchase lines outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Job Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1'' OR documentNo eq ''%2''', PurchHeader."No.", PurchHeader2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the purchase line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    local procedure AssertZeroValueResponse(Response: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        Assert.IsTrue(JObject.ReadFrom(Response), 'Invalid response format.');
        Assert.IsTrue(JObject.Get('value', JToken), 'Value token not found.');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'Response contains data outside of the filter.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestGetRcvdNotInvdPOLines()
    var
        Job: Record Job;
        PurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase order is created with received not invoiced lines
        LibJob.CreateJob(Job);
        CreatePOWithJob(PurchHeader, Job);
        LibPurch.PostPurchaseDocument(PurchHeader, true, false);
        PurchaseLine.SetRange("Job No.", Job."No.");
        Commit();

        // [WHEN] Get request for received not invoiced PO lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Job Received", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('jobNo eq ''%1''', Job."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the received not invoiced PO line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if PurchaseLine.FindSet() then
            repeat
                VerifyRcvdNotInvdPOLine(Response, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure VerifyRcvdNotInvdPOLine(Response: Text; PurchaseLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', PurchaseLine."No.")), 'Received not invoiced PO line not found.');
        Assert.AreEqual(Format(PurchaseLine."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
        Assert.AreEqual(PurchaseLine."Document No.", JsonMgt.GetValue('documentNo'), 'Document no. did not match.');
        Assert.AreEqual(PurchaseLine."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(Format(PurchaseLine.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. Rcd. Not Invoiced (Base)", 0, 9), JsonMgt.GetValue('qtyRcdNotInvoicedBase'), 'Qty. received not invoiced (base) did not match.');
        Assert.AreEqual(Format(PurchaseLine."Amt. Rcd. Not Invoiced (LCY)", 0, 9), JsonMgt.GetValue('amtRcdNotInvoicedLCY'), 'Amount received not invoiced (LCY) did not match.');
        Assert.AreEqual(PurchaseLine."Job No.", JsonMgt.GetValue('jobNo'), 'Job no. did not match.');
        Assert.AreEqual(PurchaseLine."Job Task No.", JsonMgt.GetValue('jobTaskNo'), 'Job task no. did not match.');
        Assert.AreEqual(Format(PurchaseLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Expected receipt date did not match.');
        Assert.AreEqual(Format(PurchaseLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(PurchaseLine.Description, JsonMgt.GetValue('description'), 'Description did not match.');
    end;

    local procedure CreatePOWithJob(var PurchHeader: Record "Purchase Header"; Job: Record Job)
    var
        Item: Record Item;
        Vendor: Record Vendor;
        JobTask: Record "Job Task";
        PurchLine: Record "Purchase Line";
    begin
        LibJob.CreateJobTask(Job, JobTask);
        LibPurch.CreateVendor(Vendor);
        LibPurch.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, Vendor."No.");
        PurchHeader.Validate("Vendor Cr. Memo No.", PurchHeader."No.");  // Input random Vendor Cr. Memo No.
        PurchHeader.Validate("Document Date", CalcDate(StrSubstNo('<-%1D>', LibRandom.RandInt(10)), WorkDate()));
        PurchHeader.Modify(true);
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibInv.CreateItem(Item), LibRandom.RandDec(10, 2));
        PurchLine.Validate("Job No.", JobTask."Job No.");
        PurchLine.Validate("Job Task No.", JobTask."Job Task No.");
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibInv.CreateItem(Item), LibRandom.RandDec(10, 2));
        PurchLine.Validate("Job No.", JobTask."Job No.");
        PurchLine.Validate("Job Task No.", JobTask."Job Task No.");
        PurchLine.Modify(true);
    end;

    local procedure CastToDecimal(Value: Text) Output: Decimal
    begin
        if Value = '' then
            exit(0);
        Evaluate(Output, Value);
        exit(Output);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}

#pragma warning restore AA0247
#pragma warning restore AA0137
#pragma warning restore AA0217
#pragma warning restore AA0205
#pragma warning restore AA0210