// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 55 "Caption Class Impl."
{
    Access = Internal;

    var
        CaptionClass: Codeunit "Caption Class";

    local procedure SplitCaptionClassExpr(CaptionClassExpr: Text; var CaptionArea: Text; var CaptionExpr: Text): Boolean
    var
        CommaPosition: Integer;
    begin
        CommaPosition := StrPos(CaptionClassExpr, ',');
        if CommaPosition > 0 then begin
            CaptionArea := CopyStr(CaptionClassExpr, 1, CommaPosition - 1);
            CaptionExpr := CopyStr(CaptionClassExpr, CommaPosition + 1);
            exit(true);
        end;
        exit(false);
    end;

    local procedure ResolveCaptionClass(Language: Integer; CaptionClassExpr: Text) Caption: Text
    var
        CaptionArea: Text;
        CaptionExpr: Text;
        Resolved: Boolean;
    begin
        if SplitCaptionClassExpr(CaptionClassExpr, CaptionArea, CaptionExpr) then
            if CaptionArea = '3' then begin
                Caption := CaptionExpr;
                Resolved := true;
            end else
                CaptionClass.OnResolveCaptionClass(CaptionArea, CaptionExpr, Language, Caption, Resolved);

        // if Caption hasn't been resolved, fallback to CaptionClassExpr
        if not Resolved then
            Caption := CaptionClassExpr;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"UI Helper Triggers", 'CaptionClassTranslate', '', false, false)]
    local procedure DoResolveCaptionClass(Language: Integer; CaptionExpr: Text[1024]; var Translation: Text[1024])
    begin
        Translation := CopyStr(ResolveCaptionClass(Language, CaptionExpr), 1, MaxStrLen(Translation));
        CaptionClass.OnAfterCaptionClassResolve(Language, CaptionExpr, Translation);
    end;
}
