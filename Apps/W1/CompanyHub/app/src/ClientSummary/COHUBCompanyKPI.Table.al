table 1151 "COHUB Company KPI"
{
    DataCaptionFields = "Environment Name", "Company Display Name";
    ReplicateData = false;
    DataPerCompany = false;
    Access = Internal;

    fields
    {
        field(1; "Enviroment No."; Code[20])
        {
            TableRelation = "COHUB Enviroment"."No.";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(2; "Company Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(130; "Environment Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#if not CLEAN20
#pragma warning disable AL0685
        field(3; "Name"; Text[50])
        {
            ObsoleteReason = 'Use the other field - Environment Name. This field has a wrong length.';
            ObsoleteState = Pending;
            ObsoleteTag = '20.0';

            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#pragma warning restore AL0685
#else
        field(3; "Name"; Text[50])
        {
            ObsoleteReason = 'Use the other field - Environment Name. This field has a wrong length.';
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';

            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#endif
        field(4; "Company Display Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Assigned To"; Guid)
        {
            TableRelation = User."User Security ID";
            ValidateTableRelation = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(100; "Overdue Sales Documents"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(101; "Purchase Documents Due Today"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(102; "POs Pending Approval"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(103; "SOs Pending Approval"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(104; "Approved Sales Orders"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(105; "Approved Purchase Orders"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(106; "Vendors - Payment on Hold"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(107; "Purchase Return Orders"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(108; "Sales Return Orders - All"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(109; "Enviroments - Blocked"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(110; "Overdue Purchase Documents"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(111; "Purchase Discounts Next Week"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(112; "Purch. Invoices Due Next Week"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(113; "New Incoming Documents"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(114; "Approved Incoming Documents"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(115; "OCR Pending"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(116; "OCR Completed"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(117; "Requests to Approve"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(118; "Requests Sent for Approval"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(119; "Non-Applied Payments"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(120; "Cash Accounts Balance"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            DataClassification = CustomerContent;
        }
        field(121; "Last Depreciated Posted Date"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(200; "Ongoing Sales Invoices"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(201; "Ongoing Purchase Invoices"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            DataClassification = CustomerContent;
        }
        field(202; "Sales This Month"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }

        // TODO: Not good, tied to tenant, it should be per company
        field(203; "Top 10 Company Sales YTD"; Text[30])
        {
            AutoFormatExpression = '<Precision,1:1><Standard Format,9>%';
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(204; "Overdue Purch. Invoice Amount"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(205; "Overdue Sales Invoice Amount"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(206; "Average Collection Days"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(207; "Ongoing Sales Quotes"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(208; "Sales Inv. - Pending Doc.Exch."; Text[30])
        {
            Caption = 'Sales Invoices - Pending Document Exchange';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(209; "Sales CrM. - Pending Doc.Exch."; Text[30])
        {
            Caption = 'Sales Credit Memos - Pending Document Exchange';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(210; "My Incoming Documents"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(211; "Sales Invoices Due Next Week"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(212; "Ongoing Sales Orders"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(213; "Inc. Doc. Awaiting Verfication"; Text[30])
        {
            Caption = 'Inc. Doc. Awaiting Verification';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(214; "Purchase Orders"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(215; "Last Login Date"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(216; "Contact Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(300; "Overdue Sales Documents Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(301; "Purch. Docs Due Today Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(302; "POs Pending Approval Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(303; "SOs Pending Approval Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(304; "Approved Sales Orders Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(305; "Approved Purchase Orders Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(306; "Vendors-Payment on Hold Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(307; "Purchase Return Orders Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(308; "Sales Return Orders-All Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(309; "Enviroments - Blocked Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(310; "Overdue Purch. Docs  Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(311; "Purch. Disc Next Week Style"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(312; "Purch. Inv Due Next Week Style"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(313; "New Incoming Documents Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(314; "Approved Incoming Docs Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(315; "OCR Pending Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(316; "OCR Completed Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(317; "Requests to Approve Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(318; "Req Sent for Approval Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(319; "Non-Applied Payments Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(320; "Cash Accounts Balance Style"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            DataClassification = CustomerContent;
        }
        field(321; "Last Dep Posted Date Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(400; "Ongoing Sales Invoices Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(401; "Ongoing Purch. Invoices Style"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            DataClassification = CustomerContent;
        }
        field(402; "Sales This Month Style"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(403; "Top 10 Cust Sales YTD Style"; Text[30])
        {
            AutoFormatExpression = '<Precision,1:1><Standard Format,9>%';
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(404; "Overdue Purch. Inv Amt Style"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(405; "Overdue Sales Inv Amt Style"; Text[30])
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            DataClassification = CustomerContent;
        }
        field(406; "Average Collection Days Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(407; "Ongoing Sales Quotes Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(408; "Sales Inv-Pend DocExch Style"; Text[30])
        {
            Caption = 'Sales Invoices - Pending Document Exchange';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(409; "Sales CrM-Pend DocExch Style"; Text[30])
        {
            Caption = 'Sales Credit Memos - Pending Document Exchange';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(410; "My Incoming Documents Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(411; "Sales Inv Due Next Week Style"; Text[30])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(412; "Ongoing Sales Orders Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(413; "Inc Doc Awaiting Verf Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(414; "Purchase Orders Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(415; "Last Login Date Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(416; "Contact Name Style"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(500; "Last Refreshed"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(501; "My User Task Style"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(502; "Group Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Enviroment"."Group Code" where("No." = field("Enviroment No.")));
        }

        field(510; "Currency Symbol"; Text[10])
        {
            DataClassification = CustomerContent;
        }

        field(511; "Cash Accounts Balance Decimal"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(512; "Overdue Purch. Inv. Amt. Dec."; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(513; "Overdue Sales Inv. Amt. Dec."; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Enviroment No.", "Company Name", "Assigned To")
        {
            Clustered = true;
        }
    }

    local procedure GetAmountFormat(): Text;
    begin
        exit('<Precision,0:0><Standard Format,0>');
    end;
}

