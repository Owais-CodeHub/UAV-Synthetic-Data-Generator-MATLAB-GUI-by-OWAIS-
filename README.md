# UAV Synthetic Data Generator (MATLAB GUI by OWAIS)

A lightweight **MATLAB-based graphical user interface** for generating synthetic **UAV-in-sky images** with corresponding **pixel-level segmentation masks**. This tool enables users to interactively place UAV objects on background scenes by adjusting **location, size, and rotation**, making it useful for synthetic dataset creation in computer vision and robotics research.

---

## Overview

Collecting large-scale annotated UAV datasets in real environments is often difficult due to:

- limited labeled data
- safety and operational constraints
- annotation cost
- environmental variability
- restricted flight conditions

This tool provides a simple way to generate paired **synthetic UAV images and masks** for:

- UAV detection
- UAV segmentation
- aerial object recognition
- robotic vision research
- synthetic data augmentation
- deep learning model training

---

## Features

- Single-file MATLAB GUI
- Load **background image**
- Load **UAV image**
- Automatic **background removal** from UAV patch
- Interactive adjustment of:
  - **X-position**
  - **Y-position**
  - **scale**
  - **rotation**
- Real-time preview in four display panels:
  - Background image
  - UAV image
  - Generated composite image
  - Segmentation mask
- Automatic saving of generated data into:
  - `images/`
  - `masks/`
- Same filename for each image-mask pair

---

## GUI Layout

The GUI contains four main panels:

- **Background Image**
- **UAV Image**
- **Generated Image**
- **Segmentation Mask**

This layout allows quick visualization of the full synthetic data generation process.

---

## Example Workflow

1. Load a background image
2. Load a UAV image
3. Automatically remove UAV patch background
4. Adjust UAV position on the background
5. Adjust UAV scale
6. Adjust UAV rotation
7. Preview the generated image and segmentation mask
8. Save both outputs

---

## Output Folder Structure

After saving, the tool automatically creates the following folders in the working directory:

```text
project_folder/
│
├── drone_data_gui.m
├── images/
│   ├── bg1_uav_0001.png
│   ├── bg1_uav_0002.png
│
└── masks/
    ├── bg1_uav_0001.png
    ├── bg1_uav_0002.png

@software{owais2026uavsynthetic,
  author       = {Muhammad Owais},
  title        = {UAV Synthetic Data Generator (MATLAB GUI)},
  year         = {2026},
  institution  = {Khalifa University},
  url          = {https://github.com/Owais-CodeHub/UAV-Synthetic-Data-Generator-MATLAB-GUI-by-OWAIS-}
}
