// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System.Collections;
using UnityEngine;
using TMPro;
using UnityEngine.Serialization;

/// <summary>
/// TwinUIPanel uses the scriptable object to update relevant UI
/// </summary>
public class TwinUIPanel : MonoBehaviour
{
    /// <summary>
    /// Twin Data
    /// </summary>
    [SerializeField]
    private TwinDataScriptableObject twinData;

    [SerializeField]
    private bool animateValueTransitions = true;

    [SerializeField]
    private float valueTransitionTime = 2f;

    [SerializeField]
    private TwinGameEvent onResetCommandSent;

    [Header("UI Components")]
    public TextMeshProUGUI twinNameLabel;
    
    public TextMeshProUGUI barTitle;
    public TextMeshProUGUI dial1Title;
    public TextMeshProUGUI dial2Title;
    public TextMeshProUGUI dial3Title;

    public ProgressController progressControllerBar;
    public ProgressController progressControllerDial1;
    public ProgressController progressControllerDial2;
    public ProgressController progressControllerDial3;
    public TextMeshProUGUI descriptionText;
    public GameObject descriptionPanel;
    public GameObject warningIndicator;

    private IEnumerator currentAnimation;

    /// <summary>
    /// Setup the on data updated callback.
    /// </summary>
    private void OnEnable()
    {
        if (twinData)
        {
            SetTwinData(twinData);
        }

        descriptionPanel.SetActive(false);
    }

    private void OnDisable()
    {
        UnsubscribeFromUpdate();
    }

    /// <summary>
    /// Sets the ScriptableObject containing the info for this panel.
    /// Will refresh all UI values
    /// </summary>
    /// <param name="twinData"></param>
    public void SetTwinData(TwinDataScriptableObject twinData)
    {
        UnsubscribeFromUpdate();
        this.twinData = twinData;
        this.twinData.onDataUpdated += OnDataUpdated;

        barTitle.text = twinData.TwinData.BarName;
        progressControllerBar.TelemetryRangeData = twinData.TwinData.BarRangeData;
        
        dial1Title.text = twinData.TwinData.Dial1Name;
        progressControllerDial1.TelemetryRangeData = twinData.TwinData.Dial1RangeData;        
        
        dial2Title.text = twinData.TwinData.Dial2Name;
        progressControllerDial2.TelemetryRangeData = twinData.TwinData.Dial2RangeData;
        
        dial3Title.text = twinData.TwinData.Dial3Name;
        progressControllerDial3.TelemetryRangeData = twinData.TwinData.Dial3RangeData;
        
        OnDataUpdated();

    }

    public void SendResetCommand()
    {
        onResetCommandSent.Raise(twinData);
    }

    /// <summary>
    /// Enable the Event Description panel and show the specified message
    /// </summary>
    /// <param name="eventDescription"></param>
    public void ShowEventDescription(string eventDescription)
    {
        descriptionPanel.SetActive(true);
        descriptionText.text = eventDescription;
    }

    /// <summary>
    /// Update relevant UI based on new data.
    /// </summary>
    private void OnDataUpdated()
    {
        twinNameLabel.text = twinData.TwinData.Name;
        warningIndicator.SetActive(false);
        descriptionPanel.SetActive(false);
        
        if (animateValueTransitions)
        {
            if (currentAnimation != null)
            {
                StopCoroutine(currentAnimation);
            }
            currentAnimation = AnimatePanelValues();
            StartCoroutine(currentAnimation);
        }
        else
        {
            SetUIValues();
        }
    }

    private IEnumerator AnimatePanelValues()
    {
        var startTime = Time.time;
        var elapsedTime = 0f;

        while (elapsedTime < valueTransitionTime)
        {
            elapsedTime = Time.time - startTime;
            var t = elapsedTime / valueTransitionTime;

            progressControllerBar.CurrentValue = Mathf.Lerp(
                (float)progressControllerBar.CurrentValue,
                (float)twinData.TwinData.BarValue, t);
            progressControllerDial1.CurrentValue = Mathf.Lerp(
                (float)progressControllerDial1.CurrentValue,
                (float)twinData.TwinData.Dial1Value, t);
            progressControllerDial2.CurrentValue = Mathf.Lerp(
                (float)progressControllerDial2.CurrentValue,
                (float)twinData.TwinData.Dial2Value, t);
            progressControllerDial3.CurrentValue = Mathf.Lerp(
                (float)progressControllerDial3.CurrentValue,
                (float)twinData.TwinData.Dial3Value, t);

            yield return null;
        }

        SetUIValues();
    }

    private void SetUIValues()
    {
        progressControllerBar.CurrentValue = twinData.TwinData.BarValue;
        progressControllerDial1.CurrentValue = twinData.TwinData.Dial1Value;
        progressControllerDial2.CurrentValue = twinData.TwinData.Dial2Value;
        progressControllerDial3.CurrentValue = twinData.TwinData.Dial3Value;
    }

    private void UnsubscribeFromUpdate()
    {
        if (twinData != null)
        {
            twinData.onDataUpdated -= OnDataUpdated;
        }
    }
}