codeunit 11099 "Create DE FA Depreciation Book"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertDepreciationBook(var Rec: Record "Depreciation Book")
    var
        CreateFADeprBook: Codeunit "Create FA Depreciation Book";
    begin
        case Rec.Code of
            CreateFADeprBook.Company():
                ValidateDepreciationBook(Rec, 10, true);
        end;
    end;

    local procedure ValidateDepreciationBook(var DepreciationBook: Record "Depreciation Book"; DefaultFinalRoundingAmount: Decimal; VATonNetDisposalEntries: Boolean)
    begin
        DepreciationBook.Validate("Default Final Rounding Amount", DefaultFinalRoundingAmount);
        DepreciationBook.Validate("VAT on Net Disposal Entries", VATonNetDisposalEntries);
    end;
}