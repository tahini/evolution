# installPackages.R
# Script to install required R packages if they are not already installed

# List of required packages based on project needs
required_packages <- c(
    "dplyr",     # A Grammar of Data Manipulation
    "ggplot2",   # Create Elegant Data Visualisations Using the Grammar of Graphics
    "tidyr",     # Tidy Messy Data
    "stringr",   # String Manipulation
    "here"       # A Simpler Way to Find Your Files
)

# Function to install missing packages
install_if_missing <- function(packages) {
    new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new_packages)) {
        cat("Installing missing packages:", paste(new_packages, collapse=", "), "\n")
        install.packages(new_packages, repos="https://cloud.r-project.org")
    } else {
        cat("All required packages are already installed.\n")
    }
}

# Install missing packages
install_if_missing(required_packages)

# Load all packages
cat("Loading required packages...\n")
for (pkg in required_packages) {
    cat("Loading package:", pkg, "\n")
    library(pkg, character.only = TRUE)
}

cat("Package installation and loading complete.\n")