// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// The chat roles that are available for Chat Completion.
/// </summary>
enum 7772 "AOAI Chat Roles"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// User chat role messages are the messages that the user sends to the model.
    /// </summary>
    value(0; User)
    {
        Caption = 'user', Locked = true;
    }

    /// <summary>
    /// System chat role messages provides the initial instructions to the model.
    /// </summary>
    value(1; System)
    {
        Caption = 'system', Locked = true;
    }

    /// <summary>
    /// Assistant chat role messages are the messages that the model sends to the user.
    /// </summary>
    value(2; Assistant)
    {
        Caption = 'assistant', Locked = true;
    }
}