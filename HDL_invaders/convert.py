from PIL import Image

def image_to_binary(file_path, threshold=128):
    img = Image.open(file_path)
    
    grayscale_img = img.convert('L')
    
    binary_representation = []
    
    for y in range(grayscale_img.height):
        row = []
        for x in range(grayscale_img.width):
            pixel = grayscale_img.getpixel((x, y))
            row.append(0 if pixel >= threshold else 1)
        binary_representation.append(row)
    
    return binary_representation

def flatten_extend(matrix):
    flat_list = []
    for row in matrix:
        flat_list.extend(row)
    return flat_list

def bin_list_to_hex_8bit(bin_list):
    while len(bin_list) % 8 != 0:
        bin_list.insert(0, 0)
    
    hex_list = []
    
    for i in range(0, len(bin_list), 8):
        chunk = bin_list[i:i+8]  # Get the next chunk of 8 bits
        hex_value = hex(int(''.join(map(str, chunk)), 2))[2:]  # Convert to hex and remove '0x' prefix
        
        formatted_hex = f"8'h{hex_value.zfill(2)}"  # zfill ensures it's 2 digits
        
        hex_list.append(formatted_hex)
    
    return hex_list

def main(file_pathes):
    for file_path in file_pathes:
        binary_data = flatten_extend(image_to_binary(file_path))
        s = ""
        for i in bin_list_to_hex_8bit(binary_data):
            s += f"{i}, "
        s = s[:-2]
        print(f"{file_path}: ", s)


# CHANGE YOUR IMAGE PATH
file_pathes = ['alien_debug.png']

if __name__ == "__main__":
    main(file_pathes)