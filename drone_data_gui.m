function drone_data_gui
% DRONE_DATA_GUI
% Simple single-file MATLAB GUI to generate synthetic drone-in-sky images
% and corresponding segmentation masks.
%
% Features:
% 1. Load background image
% 2. Load drone image
% 3. Automatically remove drone image background
% 4. Adjust drone X/Y location, scale, and rotation
% 5. Preview:
%    - Background image
%    - Drone image
%    - Generated composite image
%    - Segmentation mask
% 6. Save image and mask in:
%    ./images
%    ./masks
%
% Output image and mask will have the same filename.

    clc;

    % -----------------------------
    % State variables
    % -----------------------------
    S = struct();
    S.bg = [];
    S.bgName = '';
    S.droneOrig = [];
    S.droneName = '';
    S.droneRGB = [];
    S.droneAlpha = [];
    S.compImage = [];
    S.compMask = [];
    S.lastSavedIndex = 1;

    % Default transform
    S.posX = 100;
    S.posY = 100;
    S.scale = 0.3;
    S.angle = 0;

    % -----------------------------
    % Create GUI
    % -----------------------------
    fig = uifigure('Name', 'UAVs Synthetic Data Generator by MUHAMMAD OWAIS', ...
                   'Position', [100 50 1450 820], ...
                   'Color', [0.96 0.97 0.99]);

    % Title
    uilabel(fig, ...
        'Text', 'UAVs Synthetic Data Generator', ...
        'Position', [560 780 360 28], ...
        'FontSize', 22, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % -----------------------------
    % Axes Panels
    % -----------------------------
    p1 = uipanel(fig, 'Title', 'Background Image', ...
        'Position', [20 390 680 360], 'FontWeight', 'bold');
    axBG = uiaxes(p1, 'Position', [10 10 660 320]);
    axis(axBG, 'image'); axBG.XTick = []; axBG.YTick = [];

    p2 = uipanel(fig, 'Title', 'UAVs Image (Background Removed)', ...
        'Position', [730 390 680 360], 'FontWeight', 'bold');
    axDrone = uiaxes(p2, 'Position', [10 10 660 320]);
    axis(axDrone, 'image'); axDrone.XTick = []; axDrone.YTick = [];

    p3 = uipanel(fig, 'Title', 'Generated Image', ...
        'Position', [20 20 680 340], 'FontWeight', 'bold');
    axComp = uiaxes(p3, 'Position', [10 10 660 300]);
    axis(axComp, 'image'); axComp.XTick = []; axComp.YTick = [];

    p4 = uipanel(fig, 'Title', 'Segmentation Mask', ...
        'Position', [730 20 680 340], 'FontWeight', 'bold');
    axMask = uiaxes(p4, 'Position', [10 10 660 300]);
    axis(axMask, 'image'); axMask.XTick = []; axMask.YTick = [];

    % -----------------------------
    % Controls panel
    % -----------------------------
    ctrl = uipanel(fig, 'Title', 'Controls', ...
        'Position', [20 755 1390 65], 'FontWeight', 'bold');

    btnLoadBG = uibutton(ctrl, 'push', ...
        'Text', 'Load Background', ...
        'Position', [20 10 130 32], ...
        'ButtonPushedFcn', @(~,~) loadBackground());

    btnLoadDrone = uibutton(ctrl, 'push', ...
        'Text', 'Load UAVs', ...
        'Position', [165 10 130 32], ...
        'ButtonPushedFcn', @(~,~) loadDrone());

    uilabel(ctrl, 'Text', 'X', 'Position', [330 15 15 22], 'FontWeight', 'bold');
    sldX = uislider(ctrl, 'Position', [350 25 150 3], ...
        'Limits', [1 1000], 'Value', S.posX, ...
        'ValueChangedFcn', @(src,~) updateX(src.Value), ...
        'ValueChangingFcn', @(src,event) updateX(event.Value));

    uilabel(ctrl, 'Text', 'Y', 'Position', [520 15 15 22], 'FontWeight', 'bold');
    sldY = uislider(ctrl, 'Position', [540 25 150 3], ...
        'Limits', [1 1000], 'Value', S.posY, ...
        'ValueChangedFcn', @(src,~) updateY(src.Value), ...
        'ValueChangingFcn', @(src,event) updateY(event.Value));

    uilabel(ctrl, 'Text', 'Scale', 'Position', [710 15 40 22], 'FontWeight', 'bold');
    sldScale = uislider(ctrl, 'Position', [755 25 150 3], ...
        'Limits', [0.05 2.0], 'Value', S.scale, ...
        'ValueChangedFcn', @(src,~) updateScale(src.Value), ...
        'ValueChangingFcn', @(src,event) updateScale(event.Value));

    uilabel(ctrl, 'Text', 'Rotate', 'Position', [925 15 45 22], 'FontWeight', 'bold');
    sldAngle = uislider(ctrl, 'Position', [975 25 150 3], ...
        'Limits', [-180 180], 'Value', S.angle, ...
        'ValueChangedFcn', @(src,~) updateAngle(src.Value), ...
        'ValueChangingFcn', @(src,event) updateAngle(event.Value));

    btnCenter = uibutton(ctrl, 'push', ...
        'Text', 'Center Drone', ...
        'Position', [1150 10 110 32], ...
        'ButtonPushedFcn', @(~,~) centerDrone());

    btnSave = uibutton(ctrl, 'push', ...
        'Text', 'Save Image + Mask', ...
        'Position', [1275 10 100 32], ...
        'ButtonPushedFcn', @(~,~) saveOutputs());

    % -----------------------------
    % Nested functions
    % -----------------------------
    function loadBackground()
        [f, p] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'}, ...
                           'Select Background Image');
        if isequal(f, 0)
            return;
        end

        img = imread(fullfile(p, f));
        img = ensureRGB(img);

        S.bg = img;
        [~, nm, ~] = fileparts(f);
        S.bgName = nm;

        imshow(S.bg, 'Parent', axBG);
        title(axBG, sprintf('Background: %s', f), 'Interpreter', 'none');

        % Update sliders based on image size
        [h, w, ~] = size(S.bg);
        sldX.Limits = [1 w];
        sldY.Limits = [1 h];

        S.posX = round(w / 2);
        S.posY = round(h / 2);
        sldX.Value = S.posX;
        sldY.Value = S.posY;

        refreshPreview();
    end

    function loadDrone()
        [f, p] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'}, ...
                           'Select UAVs Image');
        if isequal(f, 0)
            return;
        end

        img = imread(fullfile(p, f));
        img = ensureRGB(img);

        S.droneOrig = img;
        [~, nm, ~] = fileparts(f);
        S.droneName = nm;

        [rgb, alpha] = removeDroneBackground(img);
        S.droneRGB = rgb;
        S.droneAlpha = alpha;

        showRGBAxonAxes(axDrone, S.droneRGB, S.droneAlpha);
        title(axDrone, sprintf('Drone: %s', f), 'Interpreter', 'none');

        refreshPreview();
    end

    function updateX(val)
        S.posX = round(val);
        refreshPreview();
    end

    function updateY(val)
        S.posY = round(val);
        refreshPreview();
    end

    function updateScale(val)
        S.scale = max(0.05, val);
        refreshPreview();
    end

    function updateAngle(val)
        S.angle = val;
        refreshPreview();
    end

    function centerDrone()
        if isempty(S.bg)
            uialert(fig, 'Please load a background image first.', 'Missing Background');
            return;
        end
        [h, w, ~] = size(S.bg);
        S.posX = round(w/2);
        S.posY = round(h/2);
        sldX.Value = S.posX;
        sldY.Value = S.posY;
        refreshPreview();
    end

    function refreshPreview()
        if isempty(S.bg)
            cla(axComp); cla(axMask);
            return;
        end

        if isempty(S.droneRGB) || isempty(S.droneAlpha)
            imshow(S.bg, 'Parent', axComp);
            title(axComp, 'Generated Image');
            blankMask = zeros(size(S.bg,1), size(S.bg,2), 'uint8');
            imshow(blankMask, 'Parent', axMask);
            title(axMask, 'Segmentation Mask');
            S.compImage = S.bg;
            S.compMask = blankMask;
            return;
        end

        [comp, mask] = composeDrone(S.bg, S.droneRGB, S.droneAlpha, ...
                                    S.posX, S.posY, S.scale, S.angle);

        S.compImage = comp;
        S.compMask = mask;

        imshow(S.compImage, 'Parent', axComp);
        title(axComp, sprintf('Generated | X=%d, Y=%d, Scale=%.2f, Rot=%.1f', ...
              S.posX, S.posY, S.scale, S.angle));

        imshow(S.compMask, 'Parent', axMask);
        title(axMask, 'Segmentation Mask');
    end

    function saveOutputs()
        if isempty(S.compImage) || isempty(S.compMask)
            uialert(fig, 'Nothing to save. Please load images first.', 'Save Error');
            return;
        end

        outImgDir = fullfile(pwd, 'images');
        outMaskDir = fullfile(pwd, 'masks');

        if ~exist(outImgDir, 'dir')
            mkdir(outImgDir);
        end
        if ~exist(outMaskDir, 'dir')
            mkdir(outMaskDir);
        end

        baseName = generateBaseName(outImgDir);
        imgPath  = fullfile(outImgDir,  [baseName '.png']);
        maskPath = fullfile(outMaskDir, [baseName '.png']);

        imwrite(S.compImage, imgPath);
        imwrite(S.compMask, maskPath);

        uialert(fig, sprintf('Saved successfully:\n%s\n%s', imgPath, maskPath), ...
            'Saved');
    end

    function baseName = generateBaseName(outDir)
        bgPart = 'bg';
        drPart = 'drone';

        if ~isempty(S.bgName)
            bgPart = S.bgName;
        end
        if ~isempty(S.droneName)
            drPart = S.droneName;
        end

        idx = 1;
        while true
            baseName = sprintf('%s_%s_%04d', bgPart, drPart, idx);
            if ~exist(fullfile(outDir, [baseName '.png']), 'file')
                break;
            end
            idx = idx + 1;
        end
    end
end

% =========================================================================
% Helper Functions
% =========================================================================

function img = ensureRGB(img)
    if ndims(img) == 2
        img = repmat(img, [1 1 3]);
    elseif size(img,3) == 1
        img = repmat(img, [1 1 3]);
    elseif size(img,3) > 3
        img = img(:,:,1:3);
    end
end

function [rgbOut, alphaMask] = removeDroneBackground(img)
% Remove background using corner-color estimation.
% Works well when drone is on relatively plain background.

    img = im2double(ensureRGB(img));
    [h, w, ~] = size(img);

    % Corner patches
    patchSize = max(5, round(min(h,w)*0.08));

    c1 = img(1:patchSize, 1:patchSize, :);
    c2 = img(1:patchSize, end-patchSize+1:end, :);
    c3 = img(end-patchSize+1:end, 1:patchSize, :);
    c4 = img(end-patchSize+1:end, end-patchSize+1:end, :);

    corners = cat(1, reshape(c1,[],3), reshape(c2,[],3), reshape(c3,[],3), reshape(c4,[],3));
    bgColor = median(corners, 1);

    % Color distance from estimated background
    dist = sqrt(sum((img - reshape(bgColor,1,1,3)).^2, 3));

    % Adaptive threshold
    thr = max(0.12, min(0.35, mean(dist(:))*1.5));

    alphaMask = dist > thr;

    % Cleanup
    alphaMask = imfill(alphaMask, 'holes');
    alphaMask = bwareaopen(alphaMask, max(20, round(numel(alphaMask)*0.001)));

    % Keep largest connected component
    cc = bwconncomp(alphaMask);
    if cc.NumObjects > 0
        stats = cellfun(@numel, cc.PixelIdxList);
        [~, idx] = max(stats);
        tmp = false(size(alphaMask));
        tmp(cc.PixelIdxList{idx}) = true;
        alphaMask = tmp;
    end

    alphaMask = imclose(alphaMask, strel('disk', 3));
    alphaMask = imgaussfilt(double(alphaMask), 1.0);
    alphaMask = mat2gray(alphaMask);
    alphaMask(alphaMask < 0.05) = 0;
    alphaMask(alphaMask > 1) = 1;

    rgbOut = img;
    rgbOut = im2uint8(rgbOut);
end

function showRGBAxonAxes(ax, rgb, alphaMask)
    checker = createChecker(size(rgb,1), size(rgb,2));
    out = zeros(size(rgb), 'uint8');

    for c = 1:3
        fg = double(rgb(:,:,c));
        bg = double(checker(:,:,c));
        out(:,:,c) = uint8(alphaMask .* fg + (1 - alphaMask) .* bg);
    end

    imshow(out, 'Parent', ax);
end

function checker = createChecker(h, w)
    tile = 20;
    [X, Y] = meshgrid(1:w, 1:h);
    pat = mod(floor(X/tile) + floor(Y/tile), 2);
    checker = zeros(h,w,3, 'uint8');
    checker(:,:,1) = uint8(220 + 20*pat);
    checker(:,:,2) = uint8(220 + 20*pat);
    checker(:,:,3) = uint8(220 + 20*pat);
end

function [comp, maskOut] = composeDrone(bg, droneRGB, droneAlpha, posX, posY, scale, angle)
% Place transformed drone on background using alpha blending.

    bg = im2uint8(ensureRGB(bg));
    droneRGB = im2uint8(ensureRGB(droneRGB));

    % Resize drone
    droneRGB2 = imresize(droneRGB, scale, 'bicubic');
    alpha2    = imresize(droneAlpha, scale, 'bicubic');

    % Rotate
    droneRGB2 = imrotate(droneRGB2, angle, 'bicubic', 'loose');
    alpha2    = imrotate(alpha2, angle, 'bicubic', 'loose');

    alpha2 = max(0, min(1, alpha2));
    maskBin = alpha2 > 0.2;

    [H, W, ~] = size(bg);
    [h, w, ~] = size(droneRGB2);

    comp = bg;
    maskOut = zeros(H, W, 'uint8');

    % Place with center at (posX, posY)
    x1 = round(posX - w/2);
    y1 = round(posY - h/2);
    x2 = x1 + w - 1;
    y2 = y1 + h - 1;

    % Compute overlap
    bx1 = max(1, x1);
    by1 = max(1, y1);
    bx2 = min(W, x2);
    by2 = min(H, y2);

    if bx1 > bx2 || by1 > by2
        return;
    end

    dx1 = bx1 - x1 + 1;
    dy1 = by1 - y1 + 1;
    dx2 = dx1 + (bx2 - bx1);
    dy2 = dy1 + (by2 - by1);

    patchRGB = droneRGB2(dy1:dy2, dx1:dx2, :);
    patchA   = alpha2(dy1:dy2, dx1:dx2);
    patchM   = maskBin(dy1:dy2, dx1:dx2);

    bgPatch = comp(by1:by2, bx1:bx2, :);

    for c = 1:3
        fg = double(patchRGB(:,:,c));
        bgc = double(bgPatch(:,:,c));
        blended = patchA .* fg + (1 - patchA) .* bgc;
        bgPatch(:,:,c) = uint8(blended);
    end

    comp(by1:by2, bx1:bx2, :) = bgPatch;
    maskOut(by1:by2, bx1:bx2) = uint8(patchM) * 255;
end