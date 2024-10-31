namespace Microsoft.DataMigration.GP;

table 4026 "GP Payment Terms"
{
    Extensible = false;

    fields
    {
        field(1; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(2; DUETYPE; Option)
        {
            Caption = 'Due Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Net Days","Date","EOM","None","Next Month","Months","Month/Day","Annual";
        }
        field(3; DUEDTDS; Integer)
        {
            Caption = 'Due Date/Days';
            DataClassification = CustomerContent;
        }
        field(4; DISCTYPE; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Days","Date","EOM","None","Next Month","Months","Month/Day","Annual";
        }
        field(5; DISCDTDS; Integer)
        {
            Caption = 'Discount Date/Days';
            DataClassification = CustomerContent;
        }
        field(6; DSCLCTYP; Option)
        {
            Caption = 'Discount Calculate Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Percent","Amount";
        }
        field(8; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(13; TAX; Boolean)
        {
            Caption = 'Tax';
            DataClassification = CustomerContent;
        }
        field(15; CBUVATMD; Boolean)
        {
            Caption = 'CB_Use_VAT_Mode';
            DataClassification = CustomerContent;
        }
        field(19; USEGRPER; Boolean)
        {
            Caption = 'Use Grace Periods';
            DataClassification = CustomerContent;
        }
        field(20; CalculateDateFrom; Option)
        {
            Caption = 'Calculate Date From';
            DataClassification = CustomerContent;
            OptionMembers = ,"Transaction Date","Discount Date";
        }
        field(21; CalculateDateFromDays; Integer)
        {
            Caption = 'Calculate Date From Days';
            DataClassification = CustomerContent;
        }
        field(22; DueMonth; Option)
        {
            Caption = 'Due Month';
            DataClassification = CustomerContent;
            OptionMembers = ,"January","February","March","April","May","June","July","August","September","October","November","December";
        }
        field(23; DiscountMonth; Option)
        {
            Caption = 'Discount Month';
            DataClassification = CustomerContent;
            OptionMembers = ,"January","February","March","April","May","June","July","August","September","October","November","December";
        }
        field(25; PYMTRMID_New; text[10])
        {
            Caption = 'BC-Friendly Payment Term';
            DataClassification = CustomerContent;
            InitValue = '';
        }
    }

    keys
    {
        key(PK; PYMTRMID)
        {
            Clustered = true;
        }
    }

    internal procedure GetCalculatedDateForumla(var CalculatedDateFormulaTxt: Text[50]): Boolean
    var
        HelperFunctions: Codeunit "Helper Functions";
        DueDateCalculation: DateFormula;
        DiscountDateCalculation: DateFormula;
        DueDateCalculationText: Text[50];
        DiscountDateCalculationText: Text[50];
        DateFormulaIsValid: Boolean;
    begin
        DateFormulaIsValid := false;
        DiscountDateCalculationText := HelperFunctions.CalculateDiscountDateFormula(Rec);
        CalculatedDateFormulaTxt := DiscountDateCalculationText;
        if Evaluate(DiscountDateCalculation, DiscountDateCalculationText) then begin
            if Rec.CalculateDateFrom = Rec.CalculateDateFrom::"Transaction Date" then begin
                DueDateCalculationText := HelperFunctions.CalculateDueDateFormula(Rec, false, '');
                CalculatedDateFormulaTxt := DueDateCalculationText;
            end else begin
                DueDateCalculationText := HelperFunctions.CalculateDueDateFormula(Rec, true, CopyStr(DiscountDateCalculationText, 1, 32));
                CalculatedDateFormulaTxt := DueDateCalculationText;
            end;

            if Evaluate(DueDateCalculation, DueDateCalculationText) then
                DateFormulaIsValid := true;
        end;

        exit(DateFormulaIsValid);
    end;
}

