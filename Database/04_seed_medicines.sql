USE Healthcare;
GO
INSERT INTO MedicineCategory(MedicineCategoryName, Description)
SELECT v.Name, v.Description
FROM (VALUES
    (N'Hô hấp - cảm cúm', N'Nhóm thuốc hỗ trợ khi ho, cảm, nghẹt mũi, đau họng'),
    (N'Dị ứng', N'Nhóm thuốc thường dùng khi dị ứng, mẩn ngứa, sổ mũi theo mùa'),
    (N'Da liễu - dùng ngoài', N'Nhóm thuốc và sản phẩm dùng ngoài da'),
    (N'Dụng cụ y tế', N'Nhiệt kế, máy đo, khẩu trang, băng gạc và dụng cụ sơ cứu'),
    (N'Mắt - tai - mũi', N'Dung dịch nhỏ mắt, rửa và xịt mũi')
) v(Name, Description)
WHERE NOT EXISTS (SELECT 1 FROM MedicineCategory c WHERE c.MedicineCategoryName = v.Name);
GO
DECLARE @p NVARCHAR(512) = N'Đọc kỹ hướng dẫn sử dụng, hỏi ý kiến bác sĩ hoặc dược sĩ trước khi dùng, nhất là khi đang mang thai, cho con bú, có bệnh nền hoặc đang dùng thuốc khác.';
DECLARE @t NVARCHAR(512) = N'Làm theo hướng dẫn của nhà sản xuất. Thông tin chỉ mang tính tham khảo, không thay thế tư vấn y tế.';

INSERT INTO Medicine(MedicineCategoryId, MedicineName, Unit, Description, Precaution)
SELECT c.MedicineCategoryId, v.Name, v.Unit, v.Description, v.Precaution
FROM (VALUES
    -- Giảm đau - hạ sốt
    (N'Giảm đau - hạ sốt', N'Ibuprofen 400mg', N'viên', N'Thuốc kháng viêm không steroid, giảm đau và hạ sốt', @p),
    (N'Giảm đau - hạ sốt', N'Paracetamol sủi 500mg', N'viên sủi', N'Dạng viên sủi của thuốc giảm đau, hạ sốt thông dụng', @p),
    (N'Giảm đau - hạ sốt', N'Naproxen 250mg', N'viên', N'Thuốc kháng viêm giảm đau cơ xương khớp', @p),
    (N'Giảm đau - hạ sốt', N'Aspirin 81mg', N'viên', N'Thuốc giảm đau, hạ sốt; dạng liều thấp thường dùng theo chỉ định của bác sĩ', @p),
    (N'Giảm đau - hạ sốt', N'Miếng dán giảm đau cơ khớp', N'miếng', N'Miếng dán dùng ngoài hỗ trợ giảm đau mỏi cơ, khớp', @p),
    -- Vitamin và khoáng chất
    (N'Vitamin và khoáng chất', N'Vitamin D3 1000IU', N'viên', N'Bổ sung vitamin D3 cho xương và hệ miễn dịch', @p),
    (N'Vitamin và khoáng chất', N'Vitamin B tổng hợp', N'viên', N'Bổ sung các vitamin nhóm B', @p),
    (N'Vitamin và khoáng chất', N'Kẽm 10mg', N'viên', N'Bổ sung khoáng chất kẽm', @p),
    (N'Vitamin và khoáng chất', N'Canxi và D3', N'viên', N'Bổ sung canxi kèm vitamin D3 cho xương chắc khỏe', @p),
    (N'Vitamin và khoáng chất', N'Omega-3', N'viên nang', N'Bổ sung axit béo omega-3 từ dầu cá', @p),
    (N'Vitamin và khoáng chất', N'Sắt và axit folic', N'viên', N'Bổ sung sắt và folic cho người thiếu sắt', @p),
    (N'Vitamin và khoáng chất', N'Magie B6', N'viên', N'Bổ sung magie kết hợp vitamin B6', @p),
    (N'Vitamin và khoáng chất', N'Vitamin E 400IU', N'viên nang', N'Bổ sung vitamin E chống oxy hóa', @p),
    -- Tiêu hóa
    (N'Tiêu hóa', N'Omeprazole 20mg', N'viên', N'Thuốc ức chế bơm proton, giảm tiết acid dạ dày', @p),
    (N'Tiêu hóa', N'Oresol', N'gói', N'Bột bù nước và điện giải khi mất nước', @p),
    (N'Tiêu hóa', N'Diosmectite', N'gói', N'Thuốc hỗ trợ điều trị tiêu chảy', @p),
    (N'Tiêu hóa', N'Loperamide 2mg', N'viên', N'Thuốc làm giảm nhu động ruột trong tiêu chảy', @p),
    (N'Tiêu hóa', N'Domperidone 10mg', N'viên', N'Thuốc hỗ trợ giảm buồn nôn, đầy bụng', @p),
    (N'Tiêu hóa', N'Simethicone', N'viên', N'Thuốc giảm đầy hơi, chướng bụng', @p),
    (N'Tiêu hóa', N'Lactulose', N'gói', N'Thuốc nhuận tràng hỗ trợ táo bón', @p),
    (N'Tiêu hóa', N'Than hoạt tính', N'viên', N'Hỗ trợ hấp phụ khí và độc chất trong đường tiêu hóa', @p),
    -- Hô hấp - cảm cúm
    (N'Hô hấp - cảm cúm', N'Siro ho thảo dược', N'chai', N'Siro hỗ trợ giảm ho, dịu cổ họng', @p),
    (N'Hô hấp - cảm cúm', N'Acetylcysteine 200mg', N'gói', N'Thuốc làm loãng đờm', @p),
    (N'Hô hấp - cảm cúm', N'Bromhexine 8mg', N'viên', N'Thuốc long đờm', @p),
    (N'Hô hấp - cảm cúm', N'Dextromethorphan 15mg', N'viên', N'Thuốc giảm ho khan', @p),
    (N'Hô hấp - cảm cúm', N'Viên ngậm đau họng', N'viên', N'Viên ngậm làm dịu đau rát họng', @p),
    (N'Hô hấp - cảm cúm', N'Xịt họng thảo dược', N'chai', N'Dung dịch xịt hỗ trợ giảm đau rát họng', @p),
    -- Dị ứng
    (N'Dị ứng', N'Loratadine 10mg', N'viên', N'Thuốc kháng histamin giảm triệu chứng dị ứng', @p),
    (N'Dị ứng', N'Cetirizine 10mg', N'viên', N'Thuốc kháng histamin giảm mẩn ngứa, sổ mũi', @p),
    (N'Dị ứng', N'Chlorpheniramine 4mg', N'viên', N'Thuốc kháng histamin thế hệ cũ, có thể gây buồn ngủ', @p),
    (N'Dị ứng', N'Fexofenadine 120mg', N'viên', N'Thuốc kháng histamin ít gây buồn ngủ', @p),
    -- Da liễu - dùng ngoài
    (N'Da liễu - dùng ngoài', N'Povidone-iodine 10%', N'chai', N'Dung dịch sát khuẩn vết thương ngoài da', @p),
    (N'Da liễu - dùng ngoài', N'Cồn y tế 70 độ', N'chai', N'Dung dịch sát khuẩn dụng cụ và da lành', @p),
    (N'Da liễu - dùng ngoài', N'Oxy già 3%', N'chai', N'Dung dịch rửa vết thương nhỏ', @p),
    (N'Da liễu - dùng ngoài', N'Kem bôi hydrocortisone 1%', N'tuýp', N'Kem bôi giảm viêm, ngứa ngoài da', @p),
    (N'Da liễu - dùng ngoài', N'Kem bôi clotrimazole 1%', N'tuýp', N'Kem bôi hỗ trợ điều trị nấm da', @p),
    (N'Da liễu - dùng ngoài', N'Dầu gió xanh', N'chai', N'Dầu xoa bóp giảm đau mỏi, nghẹt mũi', @p),
    -- Dụng cụ y tế
    (N'Dụng cụ y tế', N'Nhiệt kế điện tử', N'cái', N'Nhiệt kế đo nhiệt độ cơ thể', @t),
    (N'Dụng cụ y tế', N'Máy đo huyết áp bắp tay', N'cái', N'Thiết bị đo huyết áp tại nhà', @t),
    (N'Dụng cụ y tế', N'Máy đo đường huyết', N'bộ', N'Bộ máy kèm que thử đo đường huyết tại nhà', @t),
    (N'Dụng cụ y tế', N'Máy đo nồng độ oxy SpO2', N'cái', N'Thiết bị đo nồng độ oxy và nhịp tim ở đầu ngón tay', @t),
    (N'Dụng cụ y tế', N'Khẩu trang y tế 4 lớp', N'hộp', N'Khẩu trang dùng một lần', @t),
    (N'Dụng cụ y tế', N'Găng tay y tế', N'hộp', N'Găng tay dùng một lần', @t),
    (N'Dụng cụ y tế', N'Băng gạc vô trùng', N'hộp', N'Gạc băng vết thương vô trùng', @t),
    (N'Dụng cụ y tế', N'Băng cá nhân', N'hộp', N'Băng dán vết thương nhỏ', @t),
    (N'Dụng cụ y tế', N'Bông y tế', N'gói', N'Bông gòn dùng trong sơ cứu', @t),
    (N'Dụng cụ y tế', N'Bộ sơ cứu gia đình', N'bộ', N'Bộ dụng cụ sơ cứu cơ bản cho gia đình', @t),
    -- Mắt - tai - mũi
    (N'Mắt - tai - mũi', N'Nước muối sinh lý 0.9%', N'chai', N'Dung dịch natri clorid 0.9% rửa mũi, rửa vết thương', @p),
    (N'Mắt - tai - mũi', N'Thuốc nhỏ mắt natri clorid 0.9%', N'lọ', N'Dung dịch nhỏ rửa mắt', @p),
    (N'Mắt - tai - mũi', N'Nước mắt nhân tạo', N'lọ', N'Dung dịch bôi trơn, giảm khô mắt', @p),
    (N'Mắt - tai - mũi', N'Xịt mũi nước biển', N'chai', N'Dung dịch xịt vệ sinh, làm sạch mũi', @p)
) v(Category, Name, Unit, Description, Precaution)
JOIN MedicineCategory c ON c.MedicineCategoryName = v.Category
WHERE NOT EXISTS (SELECT 1 FROM Medicine m WHERE m.MedicineName = v.Name);
GO