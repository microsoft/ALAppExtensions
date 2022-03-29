table 1156 "COHUB Group Company Summary"
{
    DataCaptionFields = "Environment Name", "Company Name";
    ReplicateData = false;
    DataPerCompany = false;
    Access = Internal;

    fields
    {
        field(1; "Group Code"; Code[20])
        {
            TableRelation = "COHUB Group".Code;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(2; "Enviroment No."; Code[20])
        {
            TableRelation = "COHUB Enviroment"."No.";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(100; "Environment Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#if not CLEAN20
#pragma warning disable AL0685
        field(3; "Enviroment Name"; Text[50])
        {
            ObsoleteReason = 'Use the other field - Environment Name. This field has a wrong length.';
            ObsoleteState = Pending;
            ObsoleteTag = '20.0';

            FieldClass = FlowField;
            CalcFormula = lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#pragma warning restore AL0685
#else
        field(3; "Enviroment Name"; Text[50])
        {
            ObsoleteReason = 'Use the other field - Environment Name. This field has a wrong length.';
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';

            FieldClass = FlowField;
            CalcFormula = lookup("COHUB Enviroment".Name where("No." = field("Enviroment No.")));
        }
#endif
        field(4; Indent; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Company Display Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Company Name"; Text[50])
        {

            DataClassification = CustomerContent;
        }
        field(7; "Cash Accounts Balance"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Cash Accounts Balance" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(8; "Overdue Purch. Invoice Amount"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Purch. Invoice Amount" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(9; "Overdue Sales Invoice Amount"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Sales Invoice Amount" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(10; "Last Refreshed"; DateTime)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Last Refreshed" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(11; GroupSortOrder; Integer)
        {

            DataClassification = CustomerContent;
        }
        field(12; "Assigned To"; Guid)
        {
            TableRelation = User."User Security ID";
            ValidateTableRelation = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Contact Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Contact Name" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(14; "Overdue Sales Documents"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Sales Documents" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(15; "Purchase Documents Due Today"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Documents Due Today" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(16; "POs Pending Approval"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."POs Pending Approval" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(17; "SOs Pending Approval"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."SOs Pending Approval" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(18; "Approved Sales Orders"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Sales Orders" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(19; "Approved Purchase Orders"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Purchase Orders" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(20; "Vendors - Payment on Hold"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Vendors - Payment on Hold" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(21; "Purchase Return Orders"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Return Orders" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(22; "Sales Return Orders - All"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Return Orders - All" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(23; "Enviroments - Blocked"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Enviroments - Blocked" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(24; "Overdue Purchase Documents"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Purchase Documents" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(25; "Purchase Discounts Next Week"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Discounts Next Week" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(26; "Purch. Invoices Due Next Week"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purch. Invoices Due Next Week" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(27; "New Incoming Documents"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."New Incoming Documents" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(28; "Approved Incoming Documents"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Incoming Documents" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(29; "OCR Pending"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."OCR Pending" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(30; "OCR Completed"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."OCR Completed" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(31; "Requests to Approve"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Requests to Approve" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(32; "Requests Sent for Approval"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Requests Sent for Approval" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(33; "Non-Applied Payments"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Non-Applied Payments" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(34; "Last Depreciated Posted Date"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Last Depreciated Posted Date" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(35; "Ongoing Sales Invoices"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Invoices" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(36; "Ongoing Purchase Invoices"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Purchase Invoices" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(37; "Sales This Month"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales This Month" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(38; "Top 10 Company Sales YTD"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Top 10 Company Sales YTD" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(39; "Average Collection Days"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Average Collection Days" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(40; "Ongoing Sales Quotes"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Quotes" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(41; "Sales Inv. - Pending Doc.Exch."; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Inv. - Pending Doc.Exch." where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(42; "Sales CrM. - Pending Doc.Exch."; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales CrM. - Pending Doc.Exch." where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(43; "My Incoming Documents"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."My Incoming Documents" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(44; "Sales Invoices Due Next Week"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Invoices Due Next Week" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(45; "Ongoing Sales Orders"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Orders" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(46; "Inc. Doc. Awaiting Verfication"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Inc. Doc. Awaiting Verfication" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(47; "Purchase Orders"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Orders" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(48; "Overdue Sales Documents Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Sales Documents Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(49; "Purch. Docs Due Today Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purch. Docs Due Today Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(50; "POs Pending Approval Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."POs Pending Approval Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(51; "SOs Pending Approval Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."SOs Pending Approval Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(52; "Approved Sales Orders Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Sales Orders Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(53; "Approved Purchase Orders Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Purchase Orders Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(54; "Vendors-Payment on Hold Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Vendors-Payment on Hold Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(55; "Purchase Return Orders Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Return Orders Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(56; "Sales Return Orders-All Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Return Orders-All Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(57; "Enviroments - Blocked Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Enviroments - Blocked Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(58; "Overdue Purch. Docs  Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Purch. Docs  Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(59; "Purch. Disc Next Week Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purch. Disc Next Week Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(60; "Purch. Inv Due Next Week Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purch. Inv Due Next Week Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(61; "New Incoming Documents Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."New Incoming Documents Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(62; "Approved Incoming Docs Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Approved Incoming Docs Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(63; "OCR Pending Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."OCR Pending Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(64; "OCR Completed Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."OCR Completed Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(65; "Requests to Approve Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Requests to Approve Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(66; "Req Sent for Approval Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Req Sent for Approval Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(67; "Non-Applied Payments Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Non-Applied Payments Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(68; "Cash Accounts Balance Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Cash Accounts Balance Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(69; "Last Dep Posted Date Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Last Dep Posted Date Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(70; "Ongoing Sales Invoices Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Invoices Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(71; "Ongoing Purch. Invoices Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Purch. Invoices Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(72; "Sales This Month Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales This Month Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(73; "Top 10 Cust Sales YTD Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Top 10 Cust Sales YTD Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(74; "Overdue Purch. Inv Amt Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Purch. Inv Amt Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(75; "Overdue Sales Inv Amt Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Sales Inv Amt Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(76; "Average Collection Days Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Average Collection Days Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(77; "Ongoing Sales Quotes Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Quotes Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(78; "Sales Inv-Pend DocExch Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Inv-Pend DocExch Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(79; "Sales CrM-Pend DocExch Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales CrM-Pend DocExch Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(80; "My Incoming Documents Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."My Incoming Documents Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(81; "Sales Inv Due Next Week Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Sales Inv Due Next Week Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(82; "Ongoing Sales Orders Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Ongoing Sales Orders Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(83; "Inc Doc Awaiting Verf Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Inc Doc Awaiting Verf Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(84; "Purchase Orders Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Purchase Orders Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(85; "Last Login Date Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Last Login Date Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(86; "Contact Name Style"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Contact Name Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
        field(87; "My User Task Style"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."My User Task Style" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }

        field(90; "Currency Symbol"; Text[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Currency Symbol" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }

        field(92; "Cash Accounts Balance Decimal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Cash Accounts Balance Decimal" where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }

        field(93; "Overdue Purch. Inv Amt Decimal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Purch. Inv. Amt. Dec." where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }

        field(94; "Overdue Sales Inv. Amt. Dec."; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("COHUB Company KPI"."Overdue Sales Inv. Amt. Dec." where("Enviroment No." = field("Enviroment No."), "Company Name" = field("Company Name")));
        }
    }
    keys
    {
        key(PrimaryKey; GroupSortOrder, "Group Code")
        {
            Clustered = true;
        }
    }
}