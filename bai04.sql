-- triển khai
DELIMITER //
CREATE PROCEDURE PayHospitalFee(
    IN p_patient_id INT,
    IN p_amount DECIMAL(18,2),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_balance DECIMAL(18,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_message = 'Lỗi: Giao dịch thất bại, đã hoàn tác!';
    END;

    -- Lấy số dư ví
    SELECT balance INTO v_balance
    FROM Wallets
    WHERE patient_id = p_patient_id;
    START TRANSACTION;
    IF p_amount <= 0 THEN
        ROLLBACK;
        SET p_message = 'Lỗi: Số tiền thanh toán không hợp lệ';
    ELSEIF v_balance < p_amount THEN
        ROLLBACK;
        SET p_message = 'Lỗi: Số dư ví không đủ';
    ELSE
        UPDATE Wallets 
        SET balance = balance - p_amount 
        WHERE patient_id = p_patient_id;

        UPDATE Patient_Invoices 
        SET total_due = total_due - p_amount 
        WHERE patient_id = p_patient_id;

        COMMIT;
        SET p_message = 'Đã thanh toán thành công';
    END IF;
END //
DELIMITER ;
