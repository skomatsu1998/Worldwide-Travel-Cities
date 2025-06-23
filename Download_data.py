import kagglehub

# Download latest version
path = kagglehub.dataset_download("furkanima/worldwide-travel-cities-ratings-and-climate")

print("Path to dataset files:", path)