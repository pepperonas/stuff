document.addEventListener('DOMContentLoaded', function () {
    // DOM elements
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
    const textAsOutput = document.getElementById('text-as-output');
    const showCommands = document.getElementById('show-commands');
    const imageUpload = document.getElementById('image-upload');
    const imageWidth = document.getElementById('image-width');
    const imageCenter = document.getElementById('image-center');
    const asciiSelection = document.getElementById('ascii-selection');
    const themeSelector = document.getElementById('theme-selector');
    const updateButton = document.getElementById('update-mockup');
    const downloadButton = document.getElementById('download-mockup');
    const mockupTerminal = document.getElementById('mockup-terminal');

    // Custom background color elements
    const customBgColor = document.getElementById('custom-bg-color');
    const colorPicker = document.getElementById('color-picker');
    const applyBgColor = document.getElementById('apply-bg-color');
    const useCustomBg = document.getElementById('use-custom-bg');

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

    // Update the mockup preview
    function updateMockup() {
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

    // Insert text content into terminal
    function insertTextContent() {
        const text = customText.value;
        if (!text.trim()) return;

        if (textAsOutput.checked) {
            // Format as command output
            const outputDiv = document.createElement('div');
            outputDiv.className = 'output';
            outputDiv.textContent = text;
            terminalOutput.appendChild(outputDiv);
        } else if (showCommands.checked) {
            // Show as commands and outputs
            const lines = text.split('\n');
            let isCommand = true;

            lines.forEach(line => {
                if (line.trim()) {
                    if (isCommand) {
                        // Create command line with prompt
                        const cmdLineDiv = document.createElement('div');
                        cmdLineDiv.className = 'command-line';

                        const promptSpan = document.createElement('span');
                        promptSpan.className = 'prompt';
                        promptSpan.textContent = promptInput.value;

                        const cmdTextSpan = document.createElement('span');
                        cmdTextSpan.className = 'command-text';
                        cmdTextSpan.textContent = line;

                        cmdLineDiv.appendChild(promptSpan);
                        cmdLineDiv.appendChild(cmdTextSpan);
                        terminalOutput.appendChild(cmdLineDiv);
                    } else {
                        // Create output
                        const outputDiv = document.createElement('div');
                        outputDiv.className = 'output';
                        outputDiv.textContent = line;
                        terminalOutput.appendChild(outputDiv);
                    }
                    isCommand = !isCommand;
                }
            });
        } else {
            // Plain text
            const textDiv = document.createElement('div');
            textDiv.className = 'command';
            textDiv.textContent = text;
            terminalOutput.appendChild(textDiv);
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

    // Download mockup as image
    function downloadMockup() {
        // Use html2canvas to capture the terminal
        html2canvas(mockupTerminal, {
            backgroundColor: null,
            scale: 2,  // Higher quality
            logging: false
        }).then(canvas => {
            // Create download link
            const link = document.createElement('a');
            link.download = 'terminal-mockup.png';
            link.href = canvas.toDataURL('image/png');
            link.click();
        });
    }

    // Show/hide content controls based on selected type
    function toggleContentControls() {
        const contentType = contentTypeSelect.value;

        textControls.style.display = contentType === 'text' ? 'block' : 'none';
        imageControls.style.display = contentType === 'image' ? 'block' : 'none';
        asciiControls.style.display = contentType === 'ascii-art' ? 'block' : 'none';
    }

    // Event listeners
    updateButton.addEventListener('click', updateMockup);
    downloadButton.addEventListener('click', downloadMockup);
    contentTypeSelect.addEventListener('change', toggleContentControls);
    themeSelector.addEventListener('change', function () {
        applyTheme(this.value);
    });

    // Initial setup
    toggleContentControls();
    updateMockup();
});