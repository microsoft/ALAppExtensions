// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// The supported model types for Azure OpenAI.
/// </summary>
enum 7773 "AOAI Model Type"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Embedding model type.
    /// Details: https://aka.ms/AOAIUnderstandEmbeddings
    /// </summary>
    value(0; Embeddings)
    {
    }

    /// <summary>
    /// Completions model type.
    /// </summary>
    value(1; "Text Completions")
    {
    }

    /// <summary>
    /// Chat completions model type.
    /// </summary>
    value(2; "Chat Completions")
    {
    }
}