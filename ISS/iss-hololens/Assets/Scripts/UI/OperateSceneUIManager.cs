// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using Microsoft.MixedReality.Toolkit.UI;
using UnityEngine;

/// <summary>
/// Handles summoning the UI Panels in the Operate Scene
/// </summary>
public class OperateSceneUIManager : MonoBehaviour
{
    [Header("UI Components")]
    [SerializeField]
    private SiteOverviewUIPanel siteOverviewPanel;

    [SerializeField]
    private TwinUIPanel twinPanel;

    [SerializeField]
    private MessageBoxUI messageBoxPrefab;

    private MessageBoxUI messageBox;

    [SerializeField]
    private GameObject successPopupPrefab;

    private GameObject successPopup;

    private void Start()
    {
        twinPanel.gameObject.SetActive(false);
    }

    /// <summary>
    /// Show the Site Overview panel in the scene
    /// </summary>
    public void ShowSiteOverviewPanel(bool enableFollowMe = true)
    {
        siteOverviewPanel.gameObject.SetActive(true);
        siteOverviewPanel.GetComponent<FollowMeToggle>()?.SetFollowMeBehavior(enableFollowMe);
    }

    /// <summary>
    /// Called when a twin is selected in the scene or Site Overview Panel
    /// </summary>
    public void OnTwinSelected(TwinDataScriptableObject twinData)
    {
        twinPanel.gameObject.SetActive(true);
        twinPanel.SetTwinData(twinData);
    }

    public void OnResetCommandSent(TwinDataScriptableObject twinData)
    {
        if (messageBox == null)
        {
            messageBox = Instantiate(messageBoxPrefab);
        }

        messageBox.onDismissed += OnMessageBoxDismissed;
        messageBox.gameObject.SetActive(true);
        messageBox.ShowMessage("Reset Command Sent", $"A reset command has successfully been sent to Twin" +
                                                     $" {twinData.TwinData.Name}");
    }

    private void OnMessageBoxDismissed()
    {
        messageBox.onDismissed -= OnMessageBoxDismissed;
        ShowSuccessMessage();
    }

    /// <summary>
    /// Shows a success message panel
    /// </summary>
    private void ShowSuccessMessage()
    {
        if (successPopup == null)
        {
            successPopup = Instantiate(successPopupPrefab);
        }

        successPopup.gameObject.SetActive(true);
    }
}