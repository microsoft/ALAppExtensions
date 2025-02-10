codeunit 10783 "Create ES Payment Terms"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.SetOverwriteData(true);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDays1x30(), '30D', '', 0, Days1x30Lbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDays2x45(), '45D', '', 0, Days2x45Lbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDays3x30(), '30D', '', 0, Days3x30Lbl);
        ContosoPayments.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Payment Terms")
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec.Code of
            CreatePaymentTerms.PaymentTermsDAYS10():
                ValidateRecordFields(Rec, 10);
            CreatePaymentTerms.PaymentTermsDAYS14():
                ValidateRecordFields(Rec, 31);
            CreatePaymentTerms.PaymentTermsDAYS15():
                ValidateRecordFields(Rec, 15);
            CreatePaymentTerms.PaymentTermsM8D():
                ValidateRecordFields(Rec, 31);
            CreatePaymentTerms.PaymentTermsDAYS2():
                ValidateRecordFields(Rec, 2);
            CreatePaymentTerms.PaymentTermsDAYS21():
                ValidateRecordFields(Rec, 21);
            CreatePaymentTerms.PaymentTermsDAYS30():
                ValidateRecordFields(Rec, 30);
            CreatePaymentTerms.PaymentTermsDAYS60():
                ValidateRecordFields(Rec, 60);
            CreatePaymentTerms.PaymentTermsDAYS7():
                ValidateRecordFields(Rec, 7);
            CreatePaymentTerms.PaymentTermsCM():
                ValidateRecordFields(Rec, 31);
            CreatePaymentTerms.PaymentTermsCOD():
                ValidateRecordFields(Rec, 31);
            PaymentTermsDays1x30():
                ValidateRecordFields(Rec, 30);
            PaymentTermsDays2x45():
                ValidateRecordFields(Rec, 0);
            PaymentTermsDays3x30():
                ValidateRecordFields(Rec, 0);
        end;
    end;

    local procedure ValidateRecordFields(var PaymentTerms: Record "Payment Terms"; MaxNoofDaysTillDueDate: Integer)
    begin
        PaymentTerms.Validate("VAT distribution", PaymentTerms."VAT distribution"::Proportional);
        PaymentTerms.Validate("Calc. Pmt. Disc. on Cr. Memos", true);
        PaymentTerms.Validate("Max. No. of Days till Due Date", MaxNoofDaysTillDueDate);
    end;

    procedure PaymentTermsDays1x30(): Code[10]
    begin
        exit(Days1x30Tok);
    end;

    procedure PaymentTermsDays2x45(): Code[10]
    begin
        exit(Days2x45Tok);
    end;

    procedure PaymentTermsDays3x30(): Code[10]
    begin
        exit(Days3x30Tok);
    end;

    var
        Days1x30Tok: Label '1X30 DAYS', MaxLength = 10;
        Days2x45Tok: Label '2X45 DAYS', MaxLength = 10;
        Days3x30Tok: Label '3X30 DAYS', MaxLength = 10;
        Days1x30Lbl: Label '1 - 30 days settlement', MaxLength = 100;
        Days2x45Lbl: Label '2 - 45 and 60 days settlements', MaxLength = 100;
        Days3x30Lbl: Label '3 - 30,60,90 days settlements', MaxLength = 100;
}