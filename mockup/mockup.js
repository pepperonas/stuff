document.addEventListener('DOMContentLoaded', function () {
    // DOM elements for terminal mockup
    const terminalOutput = document.getElementById('terminal-output');
    const terminalTitleInput = document.getElementById('terminal-title-input');
    const promptInput = document.getElementById('prompt-input');
    const displayTitle = document.getElementById('display-title');
    const displayPrompt = document.getElementById('display-prompt');
    const customText = document.getElementById('custom-text');
    const contentTypeSelect = document.getElementById('content-type');
    const textControls = document.getElementById('text-controls');
    const imageControls = document.getElementById('image-controls');
    const asciiControls = document.getElementById('ascii-controls');
    const imageUpload = document.getElementById('image-upload');
    const imageWidth = document.getElementById('image-width');
    const imageCenter = document.getElementById('image-center');
    const asciiSelection = document.getElementById('ascii-selection');
    const themeSelector = document.getElementById('theme-selector');
    const updateButton = document.getElementById('update-mockup');
    const downloadButton = document.getElementById('download-mockup');
    const mockupTerminal = document.getElementById('mockup-terminal');

    // DOM elements for smartphone mockup
    const mockupSmartphone = document.getElementById('mockup-smartphone');
    const phoneModel = document.getElementById('phone-model');
    const phoneColor = document.getElementById('phone-color');
    const screenContentType = document.getElementById('screen-content-type');
    const screenshotControls = document.getElementById('screenshot-controls');
    const appControls = document.getElementById('app-controls');
    const browserControls = document.getElementById('browser-controls');
    const customScreenControls = document.getElementById('custom-screen-controls');
    const screenshotUpload = document.getElementById('screenshot-upload');
    const appTitle = document.getElementById('app-title');
    const appContent = document.getElementById('app-content');
    const browserUrl = document.getElementById('browser-url');
    const browserContent = document.getElementById('browser-content');
    const customScreenContent = document.getElementById('custom-screen-content');
    const showBattery = document.getElementById('show-battery');
    const showWifi = document.getElementById('show-wifi');
    const showSignal = document.getElementById('show-signal');
    const showTime = document.getElementById('show-time');
    const statusBarStyle = document.getElementById('status-bar-style');
    const smartphoneContent = document.getElementById('smartphone-content');

    // Mockup type selection
    const mockupTypeRadios = document.querySelectorAll('input[name="mockup-type"]');
    const terminalControls = document.getElementById('terminal-controls');
    const smartphoneControls = document.getElementById('smartphone-controls');

    // Custom background color elements
    const customBgColor = document.getElementById('custom-bg-color');
    const colorPicker = document.getElementById('color-picker');
    const applyBgColor = document.getElementById('apply-bg-color');
    const useCustomBg = document.getElementById('use-custom-bg');

    // ASCII art collection
    const asciiArt = {
        tux: `
    .--.
   |o_o |
   |:_/ |
  //   \\ \\
 (|     | )
/'\\_   _/\`\\
\\___)=(___/
        `,
        computer: `
     ,----------------,
    ,-----------------------,
  ,\"                      \",
 +--------------------------|
 |                          |
 |   .----------------------+
 |   |                     ||
 |   |                     ||
 |   |                     ||
 |   |                     ||
 |   '-----------------------+
 |                          |
 |                          |
 |                          |
 |                          |
 '--------------------------'
        `,
        linux: `
    _nnnn_
   dGGGGMMb
  @p~qp~~qMb
  M|@||@) M|
  @,----.JM|
 JS^\\__/  qKL
dZP        qKRb
dZP          qKKb
fZP            SMMb
HZM            MMMM
FqM            MMMM
__| ".        |\\dS"qML
|    \`.       | \`' \\Zq
_)      \\.___.,|     .'
\\____   )MMMMMP|   .'
     \`-'       \`--'
        `
    };

    // Initialize current mockup type
    let currentMockupType = 'terminal';

    // ======= Event Listeners =======

    // Mockup type selection
    mockupTypeRadios.forEach(radio => {
        radio.addEventListener('change', function() {
            currentMockupType = this.value;
            toggleMockupType();
        });
    });

    // Sync color picker with text input
    colorPicker.addEventListener('input', function () {
        customBgColor.value = this.value;
    });

    customBgColor.addEventListener('input', function () {
        // Validate hex color
        if (/^#[0-9A-F]{6}$/i.test(this.value)) {
            colorPicker.value = this.value;
        }
    });

    // Apply custom background color
    applyBgColor.addEventListener('click', function () {
        if (useCustomBg.checked) {
            applyCustomBgColor();
        }
    });

    // Toggle custom background color
    useCustomBg.addEventListener('change', function () {
        if (this.checked) {
            applyCustomBgColor();
        } else {
            // Reapply current theme
            applyTheme(themeSelector.value);
        }
    });

    // Phone model change
    phoneModel.addEventListener('change', function() {
        updatePhoneModel();
    });

    // Phone color change
    phoneColor.addEventListener('change', function() {
        updatePhoneColor();
    });

    // Screen content type change
    screenContentType.addEventListener('change', function() {
        toggleScreenContentControls();
    });

    // Status bar style change
    statusBarStyle.addEventListener('change', function() {
        updateStatusBarStyle();
    });

    // Show/hide status bar elements
    showBattery.addEventListener('change', toggleStatusBarElements);
    showWifi.addEventListener('change', toggleStatusBarElements);
    showSignal.addEventListener('change', toggleStatusBarElements);
    showTime.addEventListener('change', toggleStatusBarElements);

    // Terminal content type change
    contentTypeSelect.addEventListener('change', toggleContentControls);

    // Theme selector change
    themeSelector.addEventListener('change', function () {
        applyTheme(this.value);
    });

    // Update button
    updateButton.addEventListener('click', updateMockup);

    // Download button
    downloadButton.addEventListener('click', downloadMockup);

    // ======= Functions =======

    // Toggle between terminal and smartphone mockup
    function toggleMockupType() {
        if (currentMockupType === 'terminal') {
            mockupTerminal.style.display = 'flex';
            mockupSmartphone.style.display = 'none';
            terminalControls.style.display = 'block';
            smartphoneControls.style.display = 'none';
        } else {
            mockupTerminal.style.display = 'none';
            mockupSmartphone.style.display = 'flex';
            terminalControls.style.display = 'none';
            smartphoneControls.style.display = 'block';
        }
    }

    // Toggle terminal content controls based on selected type
    function toggleContentControls() {
        const contentType = contentTypeSelect.value;

        textControls.style.display = contentType === 'text' ? 'block' : 'none';
        imageControls.style.display = contentType === 'image' ? 'block' : 'none';
        asciiControls.style.display = contentType === 'ascii-art' ? 'block' : 'none';
    }

    // Toggle smartphone screen content controls
    function toggleScreenContentControls() {
        const contentType = screenContentType.value;

        screenshotControls.style.display = contentType === 'screenshot' ? 'block' : 'none';
        appControls.style.display = contentType === 'app' ? 'block' : 'none';
        browserControls.style.display = contentType === 'browser' ? 'block' : 'none';
        customScreenControls.style.display = contentType === 'custom' ? 'block' : 'none';
    }

    // Apply custom background color
    function applyCustomBgColor() {
        let color = customBgColor.value;

        // Validate hex color, default to black if invalid
        if (!/^#[0-9A-F]{6}$/i.test(color)) {
            color = '#000000';
            customBgColor.value = color;
            colorPicker.value = color;
        }

        // Apply color to terminal body and container
        document.querySelector('.terminal-body').style.backgroundColor = color;
        mockupTerminal.style.backgroundColor = color;
    }

    // Apply terminal theme
    function applyTheme(theme) {
        // Reset custom background color styles
        document.querySelector('.terminal-body').style.backgroundColor = '';
        mockupTerminal.style.backgroundColor = '';

        // Get all current classes
        const currentClasses = mockupTerminal.className.split(' ');

        // Remove any theme classes (classes that start with 'theme-')
        const nonThemeClasses = currentClasses.filter(className => !className.startsWith('theme-'));

        // Set the terminal container back to only non-theme classes
        mockupTerminal.className = nonThemeClasses.join(' ');

        // Add the selected theme class if it's not 'nord' (default)
        if (theme !== 'nord') {
            mockupTerminal.classList.add('theme-' + theme);
        }

        // If custom background is enabled, reapply it
        if (useCustomBg && useCustomBg.checked) {
            applyCustomBgColor();
        }
    }

    // Update phone model
    function updatePhoneModel() {
        const model = phoneModel.value;
        const smartphoneFrame = document.querySelector('.smartphone-frame');

        // Remove any existing model classes
        smartphoneFrame.classList.remove('iphone', 'android', 'pixel', 'samsung');

        // Add selected model class
        smartphoneFrame.classList.add(model);

        // Add/remove notch and home button based on model
        const notch = document.querySelector('.smartphone-notch');
        const homeButton = document.querySelector('.home-button');

        if (model === 'iphone') {
            if (!notch) {
                const notchElement = document.createElement('div');
                notchElement.className = 'smartphone-notch';
                document.querySelector('.smartphone-screen').prepend(notchElement);
            }
            if (!homeButton) {
                const homeButtonElement = document.createElement('div');
                homeButtonElement.className = 'home-button';
                smartphoneFrame.appendChild(homeButtonElement);
            }
        } else {
            // Remove notch and home button for non-iPhone models
            if (notch) notch.remove();
            if (homeButton) homeButton.remove();
        }
    }

    // Update phone color
    function updatePhoneColor() {
        const color = phoneColor.value;
        const smartphoneFrame = document.querySelector('.smartphone-frame');

        // Remove any existing color classes
        smartphoneFrame.classList.remove('black', 'white', 'gold', 'silver', 'blue');

        // Add selected color class
        smartphoneFrame.classList.add(color);
    }

    // Update status bar style
    function updateStatusBarStyle() {
        const style = statusBarStyle.value;
        const statusBar = document.querySelector('.smartphone-status-bar');

        statusBar.classList.remove('status-bar-light', 'status-bar-dark');
        statusBar.classList.add('status-bar-' + style);
    }

    // Toggle status bar elements
    function toggleStatusBarElements() {
        const batteryElement = document.querySelector('.status-battery');
        const wifiElement = document.querySelector('.status-wifi');
        const signalElement = document.querySelector('.status-signal');
        const timeElement = document.querySelector('.status-time');

        batteryElement.style.display = showBattery.checked ? 'block' : 'none';
        wifiElement.style.display = showWifi.checked ? 'block' : 'none';
        signalElement.style.display = showSignal.checked ? 'block' : 'none';
        timeElement.style.display = showTime.checked ? 'block' : 'none';
    }

    // Insert text content into terminal
    function insertTextContent() {
        try {
            // Get text
            var text = customText.value || "";

            // Check if empty
            if (!text.trim()) {
                return;
            }

            // Clear terminal with old-school method
            while (terminalOutput.firstChild) {
                terminalOutput.removeChild(terminalOutput.firstChild);
            }

            // Create text container
            var textDiv = document.createElement("div");
            textDiv.className = "command";

            // Insert text with simple method
            // Compatible with older browsers
            var lines = text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                // Add text for this line
                var textNode = document.createTextNode(lines[i]);
                textDiv.appendChild(textNode);

                // Add line break (except for last line)
                if (i < lines.length - 1) {
                    var br = document.createElement("br");
                    textDiv.appendChild(br);
                }
            }

            // Add to terminal
            terminalOutput.appendChild(textDiv);

            console.log("Text successfully inserted");
        } catch (error) {
            // Error fallback: Direct insertion
            console.error("Error inserting text:", error);
            try {
                terminalOutput.innerHTML = "<div class='command'>" +
                    text.replace(/\n/g, "<br>").replace(/</g, "&lt;").replace(/>/g, "&gt;") +
                    "</div>";
            } catch (e) {
                console.error("Fallback also failed:", e);
            }
        }
    }

    // Insert image content into terminal
    function insertImageContent() {
        const file = imageUpload.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (e) {
            const imageContainer = document.createElement('div');
            imageContainer.className = 'terminal-image';
            if (imageCenter.checked) {
                imageContainer.style.textAlign = 'center';
            }

            const img = document.createElement('img');
            img.src = e.target.result;
            img.style.maxWidth = imageWidth.value + '%';

            imageContainer.appendChild(img);
            terminalOutput.appendChild(imageContainer);
        };
        reader.readAsDataURL(file);
    }

    // Insert ASCII art into terminal
    function insertAsciiArt() {
        const selectedArt = asciiSelection.value;
        const artText = asciiArt[selectedArt] || '';

        const artDiv = document.createElement('div');
        artDiv.className = 'ascii-art';
        artDiv.textContent = artText;
        terminalOutput.appendChild(artDiv);
    }

    // Insert screenshot into smartphone
    function insertScreenshot() {
        const file = screenshotUpload.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (e) {
            smartphoneContent.innerHTML = '';

            const img = document.createElement('img');
            img.src = e.target.result;
            img.style.width = '100%';
            img.style.height = 'auto';

            smartphoneContent.appendChild(img);
        };
        reader.readAsDataURL(file);
    }

    // Insert app interface into smartphone
    function insertAppInterface() {
        smartphoneContent.innerHTML = '';

        const appHeader = document.createElement('div');
        appHeader.className = 'app-header';
        appHeader.textContent = appTitle.value || 'My App';

        const appContentDiv = document.createElement('div');
        appContentDiv.className = 'app-content';
        appContentDiv.innerHTML = appContent.value || '<p>App content goes here</p>';

        smartphoneContent.appendChild(appHeader);
        smartphoneContent.appendChild(appContentDiv);
    }

    // Insert browser interface into smartphone
    function insertBrowserInterface() {
        smartphoneContent.innerHTML = '';

        const browserBar = document.createElement('div');
        browserBar.className = 'browser-bar';

        const addressBar = document.createElement('div');
        addressBar.className = 'browser-address';
        addressBar.textContent = browserUrl.value || 'https://example.com';

        const browserContentDiv = document.createElement('div');
        browserContentDiv.className = 'browser-content';
        browserContentDiv.innerHTML = browserContent.value || '<p>Webpage content goes here</p>';

        browserBar.appendChild(addressBar);
        smartphoneContent.appendChild(browserBar);
        smartphoneContent.appendChild(browserContentDiv);
    }

    // Insert custom content into smartphone
    function insertCustomContent() {
        smartphoneContent.innerHTML = customScreenContent.value || '<p>Custom content goes here</p>';
    }

    // Update the mockup preview
    function updateMockup() {
        if (currentMockupType === 'terminal') {
            updateTerminalMockup();
        } else {
            updateSmartphoneMockup();
        }
    }

    // Update terminal mockup
    function updateTerminalMockup() {
        // Update title and prompt
        displayTitle.textContent = terminalTitleInput.value;
        displayPrompt.textContent = promptInput.value;

        // Clear terminal output
        terminalOutput.innerHTML = '';

        // Handle different content types
        const contentType = contentTypeSelect.value;

        switch (contentType) {
            case 'text':
                insertTextContent();
                break;
            case 'image':
                insertImageContent();
                break;
            case 'ascii-art':
                insertAsciiArt();
                break;
        }
    }

    // Update smartphone mockup
    function updateSmartphoneMockup() {
        updatePhoneModel();
        updatePhoneColor();
        updateStatusBarStyle();
        toggleStatusBarElements();

        // Update smartphone time
        const timeElement = document.querySelector('.status-time');
        const now = new Date();
        const hours = now.getHours().toString().padStart(2, '0');
        const minutes = now.getMinutes().toString().padStart(2, '0');
        timeElement.textContent = `${hours}:${minutes}`;

        // Handle different content types
        const contentType = screenContentType.value;

        switch (contentType) {
            case 'screenshot':
                insertScreenshot();
                break;
            case 'app':
                insertAppInterface();
                break;
            case 'browser':
                insertBrowserInterface();
                break;
            case 'custom':
                insertCustomContent();
                break;
        }
    }

    // Download mockup as image
    function downloadMockup() {
        // Determine which mockup to download
        const targetElement = currentMockupType === 'terminal' ? mockupTerminal : mockupSmartphone;

        // Use html2canvas to capture the mockup
        html2canvas(targetElement, {
            backgroundColor: null,
            scale: 2,  // Higher quality
            logging: false
        }).then(canvas => {
            // Create download link
            const link = document.createElement('a');
            link.download = currentMockupType + '-mockup.png';
            link.href = canvas.toDataURL('image/png');
            link.click();
        });
    }

    // Initial setup
    toggleContentControls();
    toggleScreenContentControls();
    updateMockup();
});