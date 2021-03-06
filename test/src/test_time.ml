open! Core_kernel
open  Expect_test_helpers_kernel

let utc date_string ofday_string =
  Time.of_date_ofday
    (Date.of_string date_string)
    (Time.Ofday.of_string ofday_string)
    ~zone:Time.Zone.utc

let examples = [
  Time.epoch;
  utc "2001-01-01" "00:00:00";
  utc "2013-10-07" "09:30:00";
  utc "2017-07-28" "11:57:00.000123";
]

let%expect_test "Time.Stable.With_utc_sexp.V2" =
  print_and_check_stable_type [%here] (module Time.Stable.With_utc_sexp.V2)
    examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp (1970-01-01 00:00:00.000000Z))
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp (2001-01-01 00:00:00.000000Z)) (bin_io "\000\000\000@\228'\205A"))
    ((sexp (2013-10-07 09:30:00.000000Z))
     (bin_io "\000\000\000\198\159\148\212A"))
    ((sexp (2017-07-28 11:57:00.000123Z)) (bin_io "\004\002\000\163\201^\214A")) |}];
;;

let span_examples =
  let units =
    [ Time.Span.nanosecond
    ; Time.Span.microsecond
    ; Time.Span.millisecond
    ; Time.Span.second
    ; Time.Span.minute
    ; Time.Span.hour
    ; Time.Span.day
    ]
  in
  Time.Span.zero
  :: units
  @  List.map units ~f:Time.Span.neg
  @  List.map units ~f:(fun span -> Time.Span.scale span Float.pi)

let%expect_test "Time.Span.Stable.V1" =
  print_and_check_stable_type [%here] (module struct
    include Time.Stable.Span.V1

    (* [V1] does not precisely round-trip for all suffixes. So we use a comparison that
       requires accuracy up to one part in a million. *)
    let compare t1 t2 =
      let open Time.Span in
      let magnitude = max (abs t1) (abs t2) in
      let epsilon = Time.Span.( / ) magnitude 1_000_000. in
      let diff = t1 - t2 in
      if diff < neg epsilon
      then -1
      else if diff > epsilon
      then 1
      else 0
  end)
    span_examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp   0s)
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp   1e-06ms)
     (bin_io "\149\214&\232\011.\017>"))
    ((sexp   0.001ms)
     (bin_io "\141\237\181\160\247\198\176>"))
    ((sexp   1ms)
     (bin_io "\252\169\241\210MbP?"))
    ((sexp   1s)
     (bin_io "\000\000\000\000\000\000\240?"))
    ((sexp   1m)
     (bin_io "\000\000\000\000\000\000N@"))
    ((sexp   1h)
     (bin_io "\000\000\000\000\000 \172@"))
    ((sexp   1d)
     (bin_io "\000\000\000\000\000\024\245@"))
    ((sexp   -1e-06ms)
     (bin_io "\149\214&\232\011.\017\190"))
    ((sexp   -0.001ms)
     (bin_io "\141\237\181\160\247\198\176\190"))
    ((sexp   -1ms)
     (bin_io "\252\169\241\210MbP\191"))
    ((sexp   -1s)
     (bin_io "\000\000\000\000\000\000\240\191"))
    ((sexp   -1m)
     (bin_io "\000\000\000\000\000\000N\192"))
    ((sexp   -1h)
     (bin_io "\000\000\000\000\000 \172\192"))
    ((sexp   -1d)
     (bin_io "\000\000\000\000\000\024\245\192"))
    ((sexp   3.14159e-06ms)
     (bin_io "\229;!po\252*>"))
    ((sexp   0.00314159ms)
     (bin_io "}t\128\211\132Z\202>"))
    ((sexp   3.14159ms)
     (bin_io "\195q\139\182e\188i?"))
    ((sexp   3.14159s)
     (bin_io "\024-DT\251!\t@"))
    ((sexp   3.14159m)
     (bin_io "F\234\255\158\219\143g@"))
    ((sexp   3.14159h)
     (bin_io "\162\235\015\229\221\022\198@"))
    ((sexp   3.14159d)
     (bin_io "\186\240\203k&\145\016A")) |}];
;;

let%expect_test "Time.Span.Stable.V2" =
  print_and_check_stable_type [%here] (module Time.Stable.Span.V2)
    ~cr:Comment
    span_examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp   0s)
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp   1ns)
     (bin_io "\149\214&\232\011.\017>"))
    ((sexp   1us)
     (bin_io "\141\237\181\160\247\198\176>"))
    ((sexp   1ms)
     (bin_io "\252\169\241\210MbP?"))
    ((sexp   1s)
     (bin_io "\000\000\000\000\000\000\240?"))
    ((sexp   1m)
     (bin_io "\000\000\000\000\000\000N@"))
    ((sexp   1h)
     (bin_io "\000\000\000\000\000 \172@"))
    ((sexp   1d)
     (bin_io "\000\000\000\000\000\024\245@"))
    ((sexp   -1ns)
     (bin_io "\149\214&\232\011.\017\190"))
    ((sexp   -1us)
     (bin_io "\141\237\181\160\247\198\176\190"))
    ((sexp   -1ms)
     (bin_io "\252\169\241\210MbP\191"))
    ((sexp   -1s)
     (bin_io "\000\000\000\000\000\000\240\191"))
    ((sexp   -1m)
     (bin_io "\000\000\000\000\000\000N\192"))
    ((sexp   -1h)
     (bin_io "\000\000\000\000\000 \172\192"))
    ((sexp   -1d)
     (bin_io "\000\000\000\000\000\024\245\192"))
    ((sexp   3.1415926535897931ns)
     (bin_io "\229;!po\252*>"))
    ((sexp   3.1415926535897931us)
     (bin_io "}t\128\211\132Z\202>"))
    (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
    ("sexp serialization failed to round-trip"
      (original       3.1415926535897931us)
      (sexp           3.1415926535897931us)
      (sexp_roundtrip 3.1415926535897931us))
    ((sexp   3.1415926535897931ms)
     (bin_io "\195q\139\182e\188i?"))
    ((sexp   3.1415926535897931s)
     (bin_io "\024-DT\251!\t@"))
    ((sexp   3.1415926535897927m)
     (bin_io "F\234\255\158\219\143g@"))
    ((sexp   3.1415926535897931h)
     (bin_io "\162\235\015\229\221\022\198@"))
    ((sexp   3.1415926535897936d)
     (bin_io "\186\240\203k&\145\016A")) |}];
;;
