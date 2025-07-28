// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Staff Member API (ID 30105).
/// </summary>
codeunit 30105 "Shpfy Staff Member API"
{
    Access = Internal;

    /// <summary>
    /// Retrieves staff members from Shopify and updates the local database.
    /// </summary>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    internal procedure GetStaffMembers(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
        TempStaffMember: Record "Shpfy Staff Member" temporary;
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
        Cursor: Text;
    begin
        Shop.Get(ShopCode);
        if not Shop."B2B Enabled" then
            exit;

        CommunicationMgt.SetShop(Shop.Code);

        GraphQLType := GraphQLType::GetStaffMembers;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then begin
                ExtractStaffMembers(JResponse.AsObject(), Cursor, Shop.Code, TempStaffMember);
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
                GraphQLType := GraphQLType::GetNextStaffMembers;
            end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.staffMembers.pageInfo.hasNextPage');
        CreateUpdateStaffMembers(ShopCode, TempStaffMember);
    end;

    /// <summary>
    /// Extracts staff members from the JSON response and populates the temporary staff member record.
    /// </summary>
    /// <param name="JResponse">The JSON response object.</param>
    /// <param name="Cursor">The cursor for pagination.</param>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    /// <param name="TempStaffMember">The temporary staff member record to populate.</param>
    local procedure ExtractStaffMembers(JResponse: JsonObject; var Cursor: Text; ShopCode: Code[20]; var TempStaffMember: Record "Shpfy Staff Member" temporary)
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JStaffMembers: JsonArray;
        JStaffMemberInfo: JsonObject;
        JStaffMember: JsonToken;
    begin
        if JsonHelper.GetValueAsBoolean(JResponse, 'data.staffMembers.pageInfo.hasNextPage') then
            Cursor := JsonHelper.GetValueAsText(JResponse, 'data.staffMembers.pageInfo.endCursor');
        JsonHelper.GetJsonArray(JResponse, JStaffMembers, 'data.staffMembers.edges');
        foreach JStaffMember in JStaffMembers do
            if JsonHelper.GetJsonObject(JStaffMember.AsObject(), JStaffMemberInfo, 'node') then begin
                Clear(TempStaffMember);
                TempStaffMember.Init();
                TempStaffMember."Shop Code" := ShopCode;
                TempStaffMember.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JStaffMemberInfo, 'id'));
                TempStaffMember."Account Type" := ConvertToAccountType(JsonHelper.GetValueAsText(JStaffMemberInfo, 'accountType'));
                if Evaluate(TempStaffMember."Account Type", CommunicationMgt.ConvertToCleanOptionValue(JsonHelper.GetValueAsText(JStaffMemberInfo, 'accountType'))) then;
                TempStaffMember.Active := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'active');
                TempStaffMember.Email := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'email'), 1, MaxStrLen(TempStaffMember.Email));
                TempStaffMember.Exists := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'exists');
                TempStaffMember."First Name" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'firstName'), 1, MaxStrLen(TempStaffMember."First Name"));
                TempStaffMember.Initials := CopyStr(JsonHelper.GetArrayAsText(JStaffMemberInfo, 'initials'), 1, MaxStrLen(TempStaffMember.Initials));
                TempStaffMember."Shop Owner" := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'isShopOwner');
                TempStaffMember."Last Name" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'lastName'), 1, MaxStrLen(TempStaffMember."Last Name"));
                TempStaffMember.Name := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'name'), 1, MaxStrLen(TempStaffMember.Name));
                TempStaffMember."Locale" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'locale'), 1, MaxStrLen(TempStaffMember."Locale"));
                TempStaffMember.Phone := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'phone'), 1, MaxStrLen(TempStaffMember.Phone));
                TempStaffMember.Insert(false);
            end;
    end;

    /// <summary>
    /// Creates or updates staff members in the database based on the temporary staff member record.
    /// </summary>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    /// <param name="TempStaffMember">The temporary staff member record.</param>
    local procedure CreateUpdateStaffMembers(ShopCode: Code[20]; var TempStaffMember: Record "Shpfy Staff Member" temporary)
    var
        StaffMember: Record "Shpfy Staff Member";
        Modified: Boolean;
        ProcessedStaffMembers: List of [BigInteger];
    begin
        if TempStaffMember.FindSet() then
            repeat
                if not ProcessedStaffMembers.Contains(TempStaffMember.Id) then
                    ProcessedStaffMembers.Add(TempStaffMember.Id);
                if not StaffMember.Get(ShopCode, TempStaffMember.Id) then begin
                    StaffMember.Init();
                    StaffMember.TransferFields(TempStaffMember);
                    StaffMember.Insert(false);
                end else begin
                    Modified := false;
                    if StaffMember."Account Type" <> TempStaffMember."Account Type" then begin
                        StaffMember."Account Type" := TempStaffMember."Account Type";
                        Modified := true;
                    end;
                    if StaffMember.Active <> TempStaffMember.Active then begin
                        StaffMember.Active := TempStaffMember.Active;
                        Modified := true;
                    end;
                    if StaffMember.Email <> TempStaffMember.Email then begin
                        StaffMember.Email := TempStaffMember.Email;
                        Modified := true;
                    end;
                    if StaffMember.Exists <> TempStaffMember.Exists then begin
                        StaffMember.Exists := TempStaffMember.Exists;
                        Modified := true;
                    end;
                    if StaffMember."First Name" <> TempStaffMember."First Name" then begin
                        StaffMember."First Name" := TempStaffMember."First Name";
                        Modified := true;
                    end;
                    if StaffMember.Initials <> TempStaffMember.Initials then begin
                        StaffMember.Initials := TempStaffMember.Initials;
                        Modified := true;
                    end;
                    if StaffMember."Shop Owner" <> TempStaffMember."Shop Owner" then begin
                        StaffMember."Shop Owner" := TempStaffMember."Shop Owner";
                        Modified := true;
                    end;
                    if StaffMember."Last Name" <> TempStaffMember."Last Name" then begin
                        StaffMember."Last Name" := TempStaffMember."Last Name";
                        Modified := true;
                    end;
                    if StaffMember."Locale" <> TempStaffMember."Locale" then begin
                        StaffMember."Locale" := TempStaffMember."Locale";
                        Modified := true;
                    end;
                    if StaffMember.Name <> TempStaffMember.Name then begin
                        StaffMember.Name := TempStaffMember.Name;
                        Modified := true;
                    end;
                    if StaffMember.Phone <> TempStaffMember.Phone then begin
                        StaffMember.Phone := TempStaffMember.Phone;
                        Modified := true;
                    end;
                    if Modified then
                        StaffMember.Modify(false);
                end;
            until TempStaffMember.Next() = 0;
        StaffMember.Reset();
        StaffMember.SetRange("Shop Code", ShopCode);
        if StaffMember.FindSet() then
            repeat
                if not ProcessedStaffMembers.Contains(StaffMember.Id) then
                    StaffMember.Delete(false);
            until StaffMember.Next() = 0;
    end;

    local procedure ConvertToAccountType(Value: Text): Enum "Shpfy Staff Account Type"
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Staff Account Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Staff Account Type".FromInteger(Enum::"Shpfy Staff Account Type".Ordinals().Get(Enum::"Shpfy Staff Account Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Staff Account Type"::" ");
    end;
}