import os
from pathlib import Path
from pikepdf import Pdf, PdfImage

work_dir = Path(__file__).parent
filename = work_dir / "jbig2_page.pdf"
example = Pdf.open(filename)

for i, page in enumerate(example.pages):
    for j, (name, raw_image) in enumerate(page.images.items()):
        image = PdfImage(raw_image)
        file_path = work_dir / f"{filename}-page{i:03}-img{j:03}"
        out = image.extract_to(fileprefix=file_path)
