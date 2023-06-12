// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8962 "AFS Handle Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure AddNewEntryFromNode(var AFSHandle: Record "AFS Handle" temporary; Node: XmlNode)
    var
        AFSHelperLibrary: Codeunit "AFS Helper Library";
        AFSFormatHelper: Codeunit "AFS Format Helper";
        HandleRef: RecordRef;
        HandleFieldRef: FieldRef;
        ChildNode: XmlNode;
        FieldNo: Integer;
        EntryNo: Integer;
    begin
        if AFSHandle.FindLast() then
            EntryNo := AFSHandle."Entry No." + 1
        else
            EntryNo := 1;
        AFSHandle.Init();
        AFSHandle."Entry No." := EntryNo;
        HandleRef.GetTable(AFSHandle);
        foreach ChildNode in Node.AsXmlElement().GetChildNodes() do
            if AFSHelperLibrary.GetFieldByCaption(Database::"AFS Handle", ChildNode.AsXmlElement().Name, FieldNo) then begin
                HandleFieldRef := HandleRef.Field(FieldNo);
                if HandleFieldRef.Type = HandleFieldRef.Type::DateTime then
                    HandleFieldRef.Value(AFSFormatHelper.ConvertToDateTime(ChildNode.AsXmlElement().InnerText))
                else
                    HandleFieldRef.Value(ChildNode.AsXmlElement().InnerText);
            end;
        HandleRef.SetTable(AFSHandle);
        AFSHandle.Insert();
    end;
}
