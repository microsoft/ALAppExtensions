namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Utilities;

codeunit 6229 "Sust. Purchase Copy Document"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchLineOnBeforeValidateQuantity', '', false, false)]
    local procedure OnCopyPurchLineOnBeforeValidateQuantity(var ToPurchLine: Record "Purchase Line"; FromPurchaseLine: Record "Purchase Line")
    begin
        CopyFromPuchLine(ToPurchLine, FromPurchaseLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchRcptLine', '', false, false)]
    local procedure OnAfterCopyPurchRcptLine(var ToPurchaseLine: Record "Purchase Line"; FromPurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        CopyFromPuchRcptLine(ToPurchaseLine, FromPurchRcptLine);
    end;

    local procedure CopyFromPuchLine(var ToPurchLine: Record "Purchase Line"; FromPurchaseLine: Record "Purchase Line")
    begin
        ToPurchLine."Posted Emission CO2" := 0;
        ToPurchLine."Posted Emission CH4" := 0;
        ToPurchLine."Posted Emission N2O" := 0;

        if ToPurchLine."Sust. Account No." <> FromPurchaseLine."Sust. Account No." then
            ToPurchLine.Validate("Sust. Account No.", FromPurchaseLine."Sust. Account No.");

        if ToPurchLine."Sust. Account Category" <> FromPurchaseLine."Sust. Account Category" then
            ToPurchLine.Validate("Sust. Account Category", FromPurchaseLine."Sust. Account Category");

        if ToPurchLine."Sust. Account Subcategory" <> FromPurchaseLine."Sust. Account Subcategory" then
            ToPurchLine.Validate("Sust. Account Subcategory", FromPurchaseLine."Sust. Account Subcategory");

        ToPurchLine.Validate("Emission CO2 Per Unit", FromPurchaseLine."Emission CO2 Per Unit");
        ToPurchLine.Validate("Emission CH4 Per Unit", FromPurchaseLine."Emission CH4 Per Unit");
        ToPurchLine.Validate("Emission N2O Per Unit", FromPurchaseLine."Emission N2O Per Unit");
    end;

    local procedure CopyFromPuchRcptLine(var ToPurchLine: Record "Purchase Line"; FromPurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        ToPurchLine."Posted Emission CO2" := 0;
        ToPurchLine."Posted Emission CH4" := 0;
        ToPurchLine."Posted Emission N2O" := 0;

        if ToPurchLine."Sust. Account No." <> FromPurchRcptLine."Sust. Account No." then
            ToPurchLine.Validate("Sust. Account No.", FromPurchRcptLine."Sust. Account No.");

        if ToPurchLine."Sust. Account Category" <> FromPurchRcptLine."Sust. Account Category" then
            ToPurchLine.Validate("Sust. Account Category", FromPurchRcptLine."Sust. Account Category");

        if ToPurchLine."Sust. Account Subcategory" <> FromPurchRcptLine."Sust. Account Subcategory" then
            ToPurchLine.Validate("Sust. Account Subcategory", FromPurchRcptLine."Sust. Account Subcategory");

        ToPurchLine.Validate("Emission CO2 Per Unit", FromPurchRcptLine."Emission CO2 Per Unit");
        ToPurchLine.Validate("Emission CH4 Per Unit", FromPurchRcptLine."Emission CH4 Per Unit");
        ToPurchLine.Validate("Emission N2O Per Unit", FromPurchRcptLine."Emission N2O Per Unit");
    end;
}