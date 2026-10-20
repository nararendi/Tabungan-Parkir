// ==============================================================
// GOOGLE APPS SCRIPT: PENERIMA BACKUP TABUNGAN SMK ASSALAAM
// File: Code.gs
// ==============================================================
// Petunjuk Penggunaan:
// 1. Di Google Spreadsheet Anda, buka Extensions > Apps Script
// 2. Tempel seluruh kode ini di file Code.gs (timpa kode yang lama)
// 3. Klik tombol Save / Simpan (Ctrl + S)
// 4. Klik tombol Deploy (Terapkan) di pojok kanan atas:
//    - Jika sudah pernah deploy: Manage deployments > Klik Ikon Pensil (Edit) > Version: New version > Deploy
//    - Jika baru pertama kali: New deployment > Jenis: Web App > Who has access: Anyone (Siapa saja) > Deploy
// 5. Salin URL Web App yang berakhiran "/exec" dan masukkan ke web app Tabungan
// ==============================================================

function doPost(e) {
  try {
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var payload = JSON.parse(e.postData.contents);
    var action = payload.action;

    // 1. Catat ke sheet LOG AKTIVITAS BACKUP
    var logSheet = ss.getSheetByName("LOG_BACKUP") || ss.insertSheet("LOG_BACKUP");
    if (logSheet.getLastRow() === 0) {
      logSheet.appendRow(["Timestamp", "Aksi / Event", "Detail Data"]);
      logSheet.getRange(1, 1, 1, 3).setFontWeight("bold").setBackground("#e2e8f0");
    }
    logSheet.appendRow([new Date(), action, JSON.stringify(payload.data || payload.summary || "OK")]);

    // 2. Jika FULL BACKUP, sinkronkan semua sheet
    if (action === "full_backup" || action === "sync_all") {
      // TAB SISWA
      var studentsList = payload.students || payload.data_siswa;
      if (studentsList && studentsList.length > 0) {
        var sSheet = ss.getSheetByName("Data_Siswa") || ss.insertSheet("Data_Siswa");
        sSheet.clear();
        sSheet.appendRow(["NIS", "Nama Siswa", "Kelas", "Jurusan", "Jenis Kelamin", "Saldo Kas"]);
        sSheet.getRange(1, 1, 1, 6).setFontWeight("bold").setBackground("#dcfce7");
        studentsList.forEach(function(s) {
          sSheet.appendRow([s.nis, s.name, s.class, s.major || '', s.jk || '', s.balance || 0]);
        });
      }

      // TAB TRANSAKSI SISWA
      var txList = payload.savingsTransactions || payload.transaksi_siswa;
      if (txList && txList.length > 0) {
        var txSheet = ss.getSheetByName("Transaksi_Siswa") || ss.insertSheet("Transaksi_Siswa");
        txSheet.clear();
        txSheet.appendRow(["ID Transaksi", "NIS", "Nama Siswa", "Tipe", "Nominal", "Tanggal", "Keterangan"]);
        txSheet.getRange(1, 1, 1, 7).setFontWeight("bold").setBackground("#e0e7ff");
        txList.forEach(function(t) {
          txSheet.appendRow([t.id, t.studentNis || t.student_nis, t.studentName || t.student_name, t.type, t.amount, t.date, t.note || '']);
        });
      }

      // TAB GURU & KARYAWAN
      var teachersList = payload.teachers || payload.data_guru || payload.guru;
      if (teachersList && teachersList.length > 0) {
        var tSheet = ss.getSheetByName("Data_Guru") || ss.insertSheet("Data_Guru");
        tSheet.clear();
        tSheet.appendRow(["NIP", "Nama Guru / Staf", "Jenis Kelamin", "Jabatan", "No HP", "Saldo Kas"]);
        tSheet.getRange(1, 1, 1, 6).setFontWeight("bold").setBackground("#fef9c3");
        teachersList.forEach(function(tg) {
          tSheet.appendRow([tg.nip, tg.name, tg.jk || '', tg.role || '', tg.phone || '', tg.balance || 0]);
        });
      }

      // TAB TRANSAKSI GURU
      var teacherTxList = payload.teacherSavingsTransactions || payload.transaksi_guru || payload.tabungan_guru;
      if (teacherTxList && teacherTxList.length > 0) {
        var tTxSheet = ss.getSheetByName("Transaksi_Guru") || ss.insertSheet("Transaksi_Guru");
        tTxSheet.clear();
        tTxSheet.appendRow(["ID Transaksi", "NIP", "Nama Guru / Staf", "Tipe", "Nominal", "Tanggal", "Keterangan"]);
        tTxSheet.getRange(1, 1, 1, 7).setFontWeight("bold").setBackground("#fae8ff");
        teacherTxList.forEach(function(tt) {
          tTxSheet.appendRow([tt.id, tt.teacherNip || tt.teacher_nip, tt.teacherName || tt.teacher_name, tt.type, tt.amount, tt.date, tt.note || '']);
        });
      }

      // TAB REKAP PARKIR
      var parkingList = payload.parkingLogs || payload.rekap_parkir;
      if (parkingList && parkingList.length > 0) {
        var pSheet = ss.getSheetByName("Rekap_Parkir") || ss.insertSheet("Rekap_Parkir");
        pSheet.clear();
        pSheet.appendRow(["ID Parkir", "Tanggal", "Penerimaan Retribusi", "Pengeluaran", "Keterangan"]);
        pSheet.getRange(1, 1, 1, 5).setFontWeight("bold").setBackground("#ffedd5");
        parkingList.forEach(function(p) {
          pSheet.appendRow([p.id, p.date, p.amount || 0, p.expense || 0, p.note || '']);
        });
      }
    }

    // 3. Tambah / Update Data Guru Realtime
    if ((action === "teacher_add" || action === "teacher_update") && payload.data) {
      var d = payload.data;
      var tSheet = ss.getSheetByName("Data_Guru") || ss.insertSheet("Data_Guru");
      if (tSheet.getLastRow() === 0) {
        tSheet.appendRow(["NIP", "Nama Guru / Staf", "Jenis Kelamin", "Jabatan", "No HP", "Saldo Kas"]);
        tSheet.getRange(1, 1, 1, 6).setFontWeight("bold").setBackground("#fef9c3");
      }
      var tData = tSheet.getDataRange().getValues();
      var foundRow = -1;
      var nipStr = String(d.nip || '').trim();
      for (var r = 1; r < tData.length; r++) {
        if (String(tData[r][0]).trim() === nipStr) {
          foundRow = r + 1;
          break;
        }
      }
      var rowValues = [d.nip, d.name, d.jk || '', d.role || '', d.phone || '', d.balance !== undefined ? d.balance : 0];
      if (foundRow > -1) {
        tSheet.getRange(foundRow, 1, 1, 6).setValues([rowValues]);
      } else {
        tSheet.appendRow(rowValues);
      }
    }

    // 4. Hapus Data Guru Realtime
    if (action === "teacher_delete" && payload.data) {
      var tSheet = ss.getSheetByName("Data_Guru");
      if (tSheet && tSheet.getLastRow() > 1) {
        var tData = tSheet.getDataRange().getValues();
        var nipStr = String(payload.data.nip || '').trim();
        for (var r = tData.length - 1; r >= 1; r--) {
          if (String(tData[r][0]).trim() === nipStr) {
            tSheet.deleteRow(r + 1);
            break;
          }
        }
      }
    }

    // 5. Tambah / Update Data Siswa Realtime
    if ((action === "student_add" || action === "student_update") && payload.data) {
      var d = payload.data;
      var sSheet = ss.getSheetByName("Data_Siswa") || ss.insertSheet("Data_Siswa");
      if (sSheet.getLastRow() === 0) {
        sSheet.appendRow(["NIS", "Nama Siswa", "Kelas", "Jurusan", "Jenis Kelamin", "Saldo Kas"]);
        sSheet.getRange(1, 1, 1, 6).setFontWeight("bold").setBackground("#dcfce7");
      }
      var sData = sSheet.getDataRange().getValues();
      var foundRow = -1;
      var nisStr = String(d.nis || '').trim();
      for (var r = 1; r < sData.length; r++) {
        if (String(sData[r][0]).trim() === nisStr) {
          foundRow = r + 1;
          break;
        }
      }
      var rowValues = [d.nis, d.name, d.class || '', d.major || '', d.jk || '', d.balance !== undefined ? d.balance : 0];
      if (foundRow > -1) {
        sSheet.getRange(foundRow, 1, 1, 6).setValues([rowValues]);
      } else {
        sSheet.appendRow(rowValues);
      }
    }

    // 6. Hapus Data Siswa Realtime
    if (action === "student_delete" && payload.data) {
      var sSheet = ss.getSheetByName("Data_Siswa");
      if (sSheet && sSheet.getLastRow() > 1) {
        var sData = sSheet.getDataRange().getValues();
        var nisStr = String(payload.data.nis || '').trim();
        for (var r = sData.length - 1; r >= 1; r--) {
          if (String(sData[r][0]).trim() === nisStr) {
            sSheet.deleteRow(r + 1);
            break;
          }
        }
      }
    }

    // 7. Transaksi Tabungan Siswa Realtime
    if (action === "student_savings" && payload.data) {
      var d = payload.data;
      var txSheet = ss.getSheetByName("Transaksi_Siswa") || ss.insertSheet("Transaksi_Siswa");
      if (txSheet.getLastRow() === 0) {
        txSheet.appendRow(["ID Transaksi", "NIS", "Nama Siswa", "Tipe", "Nominal", "Tanggal", "Keterangan"]);
        txSheet.getRange(1, 1, 1, 7).setFontWeight("bold").setBackground("#e0e7ff");
      }
      txSheet.appendRow([d.id, d.studentNis, d.studentName, d.type, d.amount, d.date, d.note || '']);

      // Sinkronkan saldo terkini di Data_Siswa jika ada
      var sSheet = ss.getSheetByName("Data_Siswa");
      if (sSheet && sSheet.getLastRow() > 1) {
        var sData = sSheet.getDataRange().getValues();
        var nisStr = String(d.studentNis || '').trim();
        for (var r = 1; r < sData.length; r++) {
          if (String(sData[r][0]).trim() === nisStr) {
            var newBal = (d.currentBalance !== undefined) ? d.currentBalance : 
              (d.type === 'SETOR' ? (Number(sData[r][5]) || 0) + Number(d.amount) : (Number(sData[r][5]) || 0) - Number(d.amount));
            sSheet.getRange(r + 1, 6).setValue(newBal);
            break;
          }
        }
      }
    }

    // 8. Transaksi Tabungan Guru Realtime
    if (action === "teacher_savings" && payload.data) {
      var d = payload.data;
      var tTxSheet = ss.getSheetByName("Transaksi_Guru") || ss.insertSheet("Transaksi_Guru");
      if (tTxSheet.getLastRow() === 0) {
        tTxSheet.appendRow(["ID Transaksi", "NIP", "Nama Guru / Staf", "Tipe", "Nominal", "Tanggal", "Keterangan"]);
        tTxSheet.getRange(1, 1, 1, 7).setFontWeight("bold").setBackground("#fae8ff");
      }
      tTxSheet.appendRow([d.id, d.teacherNip, d.teacherName, d.type, d.amount, d.date, d.note || '']);

      // Sinkronkan saldo terkini di Data_Guru jika ada
      var tSheet = ss.getSheetByName("Data_Guru");
      if (tSheet && tSheet.getLastRow() > 1) {
        var tData = tSheet.getDataRange().getValues();
        var nipStr = String(d.teacherNip || '').trim();
        for (var r = 1; r < tData.length; r++) {
          if (String(tData[r][0]).trim() === nipStr) {
            var newBal = (d.currentBalance !== undefined) ? d.currentBalance : 
              (d.type === 'SETOR' ? (Number(tData[r][5]) || 0) + Number(d.amount) : (Number(tData[r][5]) || 0) - Number(d.amount));
            tSheet.getRange(r + 1, 6).setValue(newBal);
            break;
          }
        }
      }
    }

    // 9. Rekap Parkir Realtime
    if (action === "parking" && payload.data) {
      var d = payload.data;
      var pSheet = ss.getSheetByName("Rekap_Parkir") || ss.insertSheet("Rekap_Parkir");
      if (pSheet.getLastRow() === 0) {
        pSheet.appendRow(["ID Parkir", "Tanggal", "Penerimaan Retribusi", "Pengeluaran", "Keterangan"]);
        pSheet.getRange(1, 1, 1, 5).setFontWeight("bold").setBackground("#ffedd5");
      }
      pSheet.appendRow([d.id, d.date, d.amount || 0, d.expense || 0, d.note || '']);
    }

    return ContentService.createTextOutput(JSON.stringify({ status: "success", message: "Data tercatat di Spreadsheet" }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch(err) {
    return ContentService.createTextOutput(JSON.stringify({ status: "error", error: err.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
