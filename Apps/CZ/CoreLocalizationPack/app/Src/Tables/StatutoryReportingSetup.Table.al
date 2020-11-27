table 31105 "Statutory Reporting Setup CZL"
{
    Caption = 'Statutory Reporting Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Company Type"; Option)
        {
            Caption = 'Company Type';
            OptionCaption = ' ,Individual,Corporate';
            OptionMembers = " ",Individual,Corporate;
            DataClassification = CustomerContent;
        }
        field(11; "Company Trade Name"; Text[100])
        {
            Caption = 'Company Trade Name';
            DataClassification = CustomerContent;
        }
        field(12; "Company Trade Name Appendix"; Text[11])
        {
            Caption = 'Company Trade Name Appendix';
            DataClassification = CustomerContent;
        }
        field(13; "Primary Business Activity"; Text[100])
        {
            Caption = 'Primary Business Activity';
            DataClassification = CustomerContent;
        }
        field(14; "Primary Business Activity Code"; Code[10])
        {
            Caption = 'Primary Business Activity Code';
            DataClassification = CustomerContent;
        }
        field(15; "Registration Date"; Date)
        {
            Caption = 'Registration Date';
            DataClassification = CustomerContent;
        }
        field(16; "Equity Capital"; Decimal)
        {
            Caption = 'Equity Capital';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(17; "Paid Equity Capital"; Decimal)
        {
            Caption = 'Paid Equity Capital';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(18; "Court Authority No."; Code[20])
        {
            Caption = 'Court Authority No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(19; "Tax Authority No."; Code[20])
        {
            Caption = 'Tax Authority No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(26; "Municipality No."; Text[30])
        {
            Caption = 'Municipality No.';
            DataClassification = CustomerContent;
        }
        field(27; Street; Text[50])
        {
            Caption = 'Street';
            DataClassification = CustomerContent;
        }
        field(28; "House No."; Text[30])
        {
            Caption = 'House No.';
            DataClassification = CustomerContent;
        }
        field(29; "Apartment No."; Text[30])
        {
            Caption = 'Apartment No.';
            DataClassification = CustomerContent;
        }
        field(40; "VAT Control Report Nos."; Code[20])
        {
            Caption = 'VAT Control Report Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(41; "Simplified Tax Document Limit"; Decimal)
        {
            Caption = 'Simplified Tax Document Limit';
            DataClassification = CustomerContent;
        }
        field(42; "Data Box ID"; Text[20])
        {
            Caption = 'Data Box ID';
            DataClassification = CustomerContent;
        }
        field(43; "VAT Control Report E-mail"; Text[80])
        {
            Caption = 'VAT Control Report E-mail';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
                EMail: Text;
            begin
                Email := "VAT Control Report E-mail";
                MailManagement.ValidateEmailAddressfield(EMail);
                "VAT Control Report E-mail" := CopyStr(EMail, 1, MaxStrLen("VAT Control Report E-mail"));
            end;
        }
        field(44; "VAT Control Report XML Format"; Enum "VAT Ctrl. Report Format CZL")
        {
            Caption = 'VAT Control Report XML Format';
            DataClassification = CustomerContent;
        }
        field(46; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            TableRelation = "VAT Statement Template";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "VAT Statement Template Name" <> xRec."VAT Statement Template Name" then
                    "VAT Statement Name" := '';
            end;
        }
        field(47; "VAT Statement Name"; Code[10])
        {
            Caption = 'VAT Statement Name';
            TableRelation = "VAT Statement Name".Name where("Statement Template Name" = field("VAT Statement Template Name"));
            DataClassification = CustomerContent;
        }
        field(51; "Tax Office Number"; Code[20])
        {
            Caption = 'Tax Office Number';
            DataClassification = CustomerContent;
        }
        field(52; "Tax Office Region Number"; Code[20])
        {
            Caption = 'Tax Office Region Number';
            DataClassification = CustomerContent;
        }
        field(61; "General Manager No."; Code[20])
        {
            Caption = 'General Manager No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(62; "Accounting Manager No."; Code[20])
        {
            Caption = 'Accounting Manager No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(63; "Finance Manager No."; Code[20])
        {
            Caption = 'Finance Manager No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(72; "Individual First Name"; Text[30])
        {
            Caption = 'Individual First Name';
            DataClassification = CustomerContent;
        }
        field(73; "Individual Surname"; Text[30])
        {
            Caption = 'Individual Surname';
            DataClassification = CustomerContent;
        }
        field(74; "Individual Title"; Text[30])
        {
            Caption = 'Individual Title';
            DataClassification = CustomerContent;
        }
        field(76; "Individual Employee No."; Code[20])
        {
            Caption = 'Individual Employee No.';
            DataClassification = CustomerContent;
        }
        field(80; "Official Code"; Text[2])
        {
            Caption = 'Official Code';
            DataClassification = CustomerContent;
        }
        field(81; "Official Name"; Text[30])
        {
            Caption = 'Official Name';
            DataClassification = CustomerContent;
        }
        field(82; "Official First Name"; Text[30])
        {
            Caption = 'Official First Name';
            DataClassification = CustomerContent;
        }
        field(83; "Official Surname"; Text[30])
        {
            Caption = 'Official Surname';
            DataClassification = CustomerContent;
        }
        field(85; "Official Birth Date"; Date)
        {
            Caption = 'Official Birth Date';
            DataClassification = CustomerContent;
        }
        field(87; "Official Reg.No.of Tax Adviser"; Text[36])
        {
            Caption = 'Official Registration No. of Tax Adviser';
            DataClassification = CustomerContent;
        }
        field(88; "Official Registration No."; Text[20])
        {
            Caption = 'Official Registration No.';
            DataClassification = CustomerContent;
        }
        field(89; "Official Type"; Option)
        {
            Caption = 'Official Type';
            OptionCaption = ' ,Individual,Corporate';
            OptionMembers = " ",Individual,Corporate;
            DataClassification = CustomerContent;
        }
        field(90; "Company Official Nos."; Code[20])
        {
            Caption = 'Company Official Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(91; "VAT Statement Country Name"; Text[25])
        {
            Caption = 'VAT Statement Country Name';
            DataClassification = CustomerContent;
        }
        field(92; "VAT Stat. Auth. Employee No."; Code[20])
        {
            Caption = 'VAT Statement Authority Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(93; "VAT Stat. Filled Employee No."; Code[20])
        {
            Caption = 'VAT Statement Filled by Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(100; "Tax Payer Status"; Option)
        {
            Caption = 'Tax Payer Status';
            OptionCaption = 'Payer,Non-payer,Other,VAT Group';
            OptionMembers = Payer,"Non-payer",Other,"VAT Group";
            DataClassification = CustomerContent;
        }
        field(110; "VIES Declaration Nos."; Code[20])
        {
            Caption = 'VIES Declaration Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(111; "VIES Decl. Auth. Employee No."; Code[20])
        {
            Caption = 'VIES Decl. Authorized Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(112; "VIES Decl. Filled Employee No."; Code[20])
        {
            Caption = 'VIES Decl. Filled Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;
        }
        field(116; "VIES Declaration Report No."; Integer)
        {
            Caption = 'VIES Declaration Report No.';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Report));
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("VIES Declaration Report Name");
            end;
        }
        field(117; "VIES Declaration Report Name"; Text[250])
        {
            Caption = 'VIES Declaration Report Name';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report),
                                                                          "Object ID" = field("VIES Declaration Report No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "VIES Number of Lines"; Integer)
        {
            Caption = 'VIES Number of Lines';
            MaxValue = 27;
            MinValue = 0;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(125; "VIES Declaration Export No."; Integer)
        {
            Caption = 'VIES Declaration Export No.';
            TableRelation = AllObj."Object ID" where("Object Type" = const(XMLport));
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("VIES Declaration Export Name");
            end;
        }
        field(126; "VIES Declaration Export Name"; Text[250])
        {
            Caption = 'VIES Declaration Export Name';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(XMLport),
                                                                          "Object ID" = field("VIES Declaration Export No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
